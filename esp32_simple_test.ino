#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

void setup() {
  Serial.begin(115200);
  Serial.println("Starting ESP32 BLE Test...");
  
  // Initialize BLE
  BLEDevice::init("cheesekeeper");
  Serial.println("BLE Device initialized");
  
  // Create BLE Server
  BLEServer* pServer = BLEDevice::createServer();
  Serial.println("BLE Server created");
  
  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMaxPreferred(0x12);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE Advertising started!");
  Serial.println("Device name: cheesekeeper");
  Serial.println("You should now see this device in BLE scanners");
  
  // Setup LED for status
  pinMode(2, OUTPUT);
}

void loop() {
  // Blink LED to show ESP32 is running
  digitalWrite(2, HIGH);
  delay(500);
  digitalWrite(2, LOW);
  delay(500);
  
  Serial.println("ESP32 is running and advertising...");
}