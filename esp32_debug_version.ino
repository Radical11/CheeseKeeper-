#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <ArduinoJson.h>
#include <Preferences.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include <BLE2902.h>
#include "mbedtls/sha256.h" // For SHA-256 Hashing

// --- Configuration ---
#define DEVICE_NAME "cheesekeeper"
#define LED_PIN 2
#define SCRAMBLE_KEY 0xAB // For password auth obfuscation ONLY

// BLE Service and Characteristic UUIDs
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CMD_CHAR_UUID       "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define RSP_CHAR_UUID       "beb5483f-36e1-4688-b7f5-ea07361b26a8"
#define MAX_PAYLOAD_LENGTH  512 // Increased for AES ciphertext

// --- Global Objects ---
Preferences prefs;
BLECharacteristic *pResponseCharacteristic;
BLEServer *pServer;
bool deviceConnected = false;
bool isAuthenticated = false;
bool bleInitialized = false;

// --- Utility Functions ---
void setLed(bool on) {
    digitalWrite(LED_PIN, on ? HIGH : LOW);
}

void scramble(char *data) {
    for (int i = 0; data[i] != '\0'; i++) {
        data[i] = data[i] ^ SCRAMBLE_KEY;
    }
}

// Function to calculate SHA-256 hash
String calculateSHA256(const char* data) {
    byte hash[32];
    mbedtls_sha256_context ctx;
    mbedtls_sha256_init(&ctx);
    mbedtls_sha256_starts(&ctx, 0); // 0 for SHA-256
    mbedtls_sha256_update(&ctx, (const unsigned char*)data, strlen(data));
    mbedtls_sha256_finish(&ctx, hash);
    mbedtls_sha256_free(&ctx);

    char hash_str[65];
    for (int i = 0; i < 32; i++) {
        sprintf(hash_str + i * 2, "%02x", hash[i]);
    }
    hash_str[64] = 0;
    return String(hash_str);
}

void sendResponse(const char* status, const char* data) {
    if (deviceConnected && pResponseCharacteristic) {
        JsonDocument doc;
        doc["status"] = status;
        doc["data"] = data;

        String output;
        serializeJson(doc, output);
        
        Serial.println("Sending response: " + output);
        
        pResponseCharacteristic->setValue((uint8_t*)output.c_str(), output.length());
        pResponseCharacteristic->notify();
    } else {
        Serial.println("Cannot send response - not connected or characteristic null");
    }
}

// --- Command Handler ---
void handleCommand(const std::string &value) {
    Serial.println("Received command: " + String(value.c_str()));
    
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, value);

    if (error) {
        Serial.println("JSON parsing failed: " + String(error.c_str()));
        sendResponse("0", "Invalid JSON");
        return;
    }

    const char* command = doc["command"];
    Serial.println("Command: " + String(command));
    
    if (strcmp(command, "login") == 0) {
        char payload[128];
        strlcpy(payload, doc["payload"], sizeof(payload));
        scramble(payload); // Unscramble received password

        String receivedHash = calculateSHA256(payload);
        String storedHash = prefs.getString("authPassHash", "");
        
        Serial.println("Login attempt - stored hash length: " + String(storedHash.length()));
        
        if (storedHash.length() > 0 && receivedHash == storedHash) {
            isAuthenticated = true;
            setLed(true);
            String encryptedFragment = prefs.getString("aesFragment", "");
            Serial.println("Login successful");
            sendResponse("2", encryptedFragment.c_str());
        } else {
            Serial.println("Login failed");
            sendResponse("0", "Login Failed");
        }
    } 
    else if (strcmp(command, "setPassword") == 0) {
        char payload[128];
        strlcpy(payload, doc["payload"], sizeof(payload));
        scramble(payload); // Unscramble new password
        
        String passwordHash = calculateSHA256(payload);
        prefs.putString("authPassHash", passwordHash);
        
        isAuthenticated = true;
        setLed(true);
        Serial.println("Password set successfully");
        sendResponse("1", "Password Set Successfully");
    }
    else if (strcmp(command, "storeFragment") == 0) {
        if (!isAuthenticated) {
            Serial.println("Store fragment attempted without authentication");
            sendResponse("0", "Not Authenticated");
            return;
        }
        const char* payload = doc["payload"];
        if (strlen(payload) > MAX_PAYLOAD_LENGTH - 1) {
             Serial.println("Payload too large");
             sendResponse("0", "Error: Payload too large.");
             return;
        }
        prefs.putString("aesFragment", payload);
        Serial.println("Fragment stored");
        sendResponse("0", "Encrypted fragment stored.");
    } 
    else if (strcmp(command, "logout") == 0) {
        isAuthenticated = false;
        setLed(false); // Turn off LED to indicate logged out but connected
        Serial.println("Logout successful");
        sendResponse("3", "Logout Successful");
    }
    else {
        Serial.println("Unknown command: " + String(command));
        sendResponse("0", "Unknown command");
    }
}

// --- BLE Callbacks ---
class ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        Serial.println("Client connected!");
        Serial.println("Client address: " + String(pServer->getConnId()));
    }
    
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        isAuthenticated = false;
        setLed(false);
        Serial.println("Client disconnected - restarting advertising");
        
        // Restart advertising after disconnect
        delay(500); // Give some time for cleanup
        BLEDevice::startAdvertising();
        Serial.println("Advertising restarted");
    }
};

class CommandCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value.length() > 0) {
            handleCommand(value.c_str());
        }
    }
};

// --- Main Setup & Loop ---
void setup() {
    // Disable brownout detector
    WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
    setCpuFrequencyMhz(80);

    // Initialize Serial for debugging
    Serial.begin(115200);
    Serial.println();
    Serial.println("=== CheeseKeeper ESP32 Starting ===");
    
    // Initialize LED
    pinMode(LED_PIN, OUTPUT);
    setLed(false);
    Serial.println("LED initialized");

    // Initialize preferences
    prefs.begin("cheesekeeper", false);
    Serial.println("Preferences initialized");

    // Initialize BLE
    Serial.println("Initializing BLE...");
    BLEDevice::init(DEVICE_NAME);
    Serial.println("BLE Device initialized with name: " + String(DEVICE_NAME));
    
    // Create BLE Server
    pServer = BLEDevice::createServer();
    if (pServer == nullptr) {
        Serial.println("ERROR: Failed to create BLE server!");
        return;
    }
    pServer->setCallbacks(new ServerCallbacks());
    Serial.println("BLE Server created and callbacks set");
    
    // Create BLE Service
    BLEService *pService = pServer->createService(SERVICE_UUID);
    if (pService == nullptr) {
        Serial.println("ERROR: Failed to create BLE service!");
        return;
    }
    Serial.println("BLE Service created with UUID: " + String(SERVICE_UUID));

    // Create Response Characteristic (for notifications)
    pResponseCharacteristic = pService->createCharacteristic(
        RSP_CHAR_UUID,
        BLECharacteristic::PROPERTY_NOTIFY
    );
    if (pResponseCharacteristic == nullptr) {
        Serial.println("ERROR: Failed to create response characteristic!");
        return;
    }
    pResponseCharacteristic->addDescriptor(new BLE2902());
    Serial.println("Response characteristic created");

    // Create Command Characteristic (for writing)
    BLECharacteristic *pCommandCharacteristic = pService->createCharacteristic(
        CMD_CHAR_UUID,
        BLECharacteristic::PROPERTY_WRITE
    );
    if (pCommandCharacteristic == nullptr) {
        Serial.println("ERROR: Failed to create command characteristic!");
        return;
    }
    pCommandCharacteristic->setCallbacks(new CommandCallbacks());
    Serial.println("Command characteristic created");

    // Start the service
    pService->start();
    Serial.println("BLE Service started");

    // Configure and start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    
    // Set advertising parameters for better compatibility
    pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
    pAdvertising->setMaxPreferred(0x12);
    
    BLEDevice::startAdvertising();
    Serial.println("BLE Advertising started!");
    Serial.println("ESP32 is now discoverable as: " + String(DEVICE_NAME));
    Serial.println("Service UUID: " + String(SERVICE_UUID));
    
    bleInitialized = true;
    Serial.println("=== Setup Complete - Ready for connections ===");
    
    // Flash LED to indicate ready
    for (int i = 0; i < 3; i++) {
        setLed(true);
        delay(200);
        setLed(false);
        delay(200);
    }
}

void loop() {
    static unsigned long lastStatusTime = 0;
    static unsigned long lastBlinkTime = 0;
    
    // Print status every 10 seconds
    if (millis() - lastStatusTime > 10000) {
        Serial.println("Status - Connected: " + String(deviceConnected ? "YES" : "NO") + 
                      ", Authenticated: " + String(isAuthenticated ? "YES" : "NO"));
        lastStatusTime = millis();
    }
    
    // Handle LED blinking based on state
    if (deviceConnected && !isAuthenticated) {
        // Slow blink when connected but not authenticated
        if (millis() - lastBlinkTime > 1000) {
            digitalWrite(LED_PIN, !digitalRead(LED_PIN));
            lastBlinkTime = millis();
        }
    } else if (!deviceConnected) {
        // Fast blink when not connected (advertising)
        if (millis() - lastBlinkTime > 250) {
            digitalWrite(LED_PIN, !digitalRead(LED_PIN));
            lastBlinkTime = millis();
        }
    } else if (isAuthenticated) {
        // Solid on when authenticated
        setLed(true);
    }
    
    delay(100); // Small delay to prevent busy-looping
}