/*
 * Simple BLE Scanner Test
 * Upload this to a second ESP32 to test if your CheeseKeeper ESP32 is advertising properly
 */

#include <BLEDevice.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

BLEScan* pBLEScan;
int scanTime = 5; //In seconds

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
      Serial.print("Advertised Device: ");
      Serial.println(advertisedDevice.toString().c_str());
      
      // Check if this is our CheeseKeeper device
      if (advertisedDevice.haveName() && advertisedDevice.getName() == "cheesekeeper") {
        Serial.println("*** FOUND CHEESEKEEPER DEVICE! ***");
        Serial.println("Name: " + String(advertisedDevice.getName().c_str()));
        Serial.println("Address: " + String(advertisedDevice.getAddress().toString().c_str()));
        Serial.println("RSSI: " + String(advertisedDevice.getRSSI()));
        
        if (advertisedDevice.haveServiceUUID()) {
          Serial.println("Service UUID: " + String(advertisedDevice.getServiceUUID().toString().c_str()));
        }
        Serial.println("=====================================");
      }
    }
};

void setup() {
  Serial.begin(115200);
  Serial.println("=== BLE Scanner Test for CheeseKeeper ===");
  Serial.println("Scanning for BLE devices...");

  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan(); //create new scan
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true); //active scan uses more power, but get results faster
  pBLEScan->setInterval(100);
  pBLEScan->setWindow(99);  // less or equal setInterval value
}

void loop() {
  Serial.println("\n--- Starting BLE Scan ---");
  BLEScanResults foundDevices = pBLEScan->start(scanTime, false);
  Serial.print("Devices found: ");
  Serial.println(foundDevices.getCount());
  Serial.println("Scan done!");
  pBLEScan->clearResults();   // delete results fromBLEScan buffer to release memory
  delay(2000);
}