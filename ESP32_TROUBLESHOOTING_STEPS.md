# ESP32 Bluetooth Fix - Step by Step Guide

## 🔧 **Step 1: Test with Simple Code**

1. **Upload the simple test code** (`esp32_simple_test.ino`) to your ESP32 first
2. **Open Serial Monitor** at 115200 baud rate
3. **Look for this output:**
   ```
   Starting ESP32 BLE Test...
   BLE Device initialized
   BLE Server created
   BLE Advertising started!
   Device name: cheesekeeper
   ESP32 is running and advertising...
   ```

4. **Check the LED:** It should blink every second
5. **Test the Flutter app:** Try connecting - you should see "🎯 Found target device: cheesekeeper!"

## 🔧 **Step 2: If Simple Test Works**

If the simple test works, upload the full CheeseKeeper code (`esp32_cheesekeeper_fixed.ino`):

1. **Upload the fixed code**
2. **Check Serial Monitor** for:
   ```
   ======================================
       CheeseKeeper ESP32 Starting
   ======================================
   ✓ LED initialized
   ✓ Preferences initialized
   ✓ BLE Device initialized: cheesekeeper
   ✓ BLE Server created
   ✓ BLE Service created
   ✓ Response characteristic created
   ✓ Command characteristic created
   ✓ BLE Service started
   ✓ BLE Advertising started!
   ESP32 is ready and advertising as:
   Device Name: cheesekeeper
   ```

3. **LED should flash 3 times, then blink rapidly** (indicating advertising)

## 🔧 **Step 3: If Nothing Works**

### Check Hardware:
1. **Power:** Make sure ESP32 has stable power (try different USB cable/port)
2. **Board:** Try pressing the RESET button on ESP32
3. **Upload:** Make sure code uploads successfully without errors

### Check Arduino IDE Settings:
1. **Board:** Select correct ESP32 board (ESP32 Dev Module)
2. **Port:** Select correct COM port
3. **Libraries:** Install required libraries:
   - ArduinoJson
   - ESP32 BLE Arduino (should be built-in)

### Check Serial Monitor:
1. **Baud Rate:** Set to 115200
2. **Connection:** Make sure ESP32 is connected via USB
3. **Errors:** Look for any error messages during startup

## 🔧 **Step 4: Common Issues & Solutions**

### Issue: "Brownout detector was triggered"
**Solution:** Use better power supply or add `WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);`

### Issue: "BLE initialization failed"
**Solution:** Try different ESP32 board or reset the ESP32

### Issue: "No serial output at all"
**Solution:** 
- Check USB cable
- Check COM port selection
- Try different USB port
- Press RESET button while connected

### Issue: "Code uploads but ESP32 doesn't run"
**Solution:**
- Press RESET button after upload
- Check if ESP32 enters bootloader mode (hold BOOT button while pressing RESET)

## 🔧 **Step 5: Verify Connection**

Once ESP32 is advertising, your Flutter app should show:

```
[BluetoothService] 📡 Found device: "cheesekeeper" (platform: "cheesekeeper", adv: "cheesekeeper") [XX:XX:XX:XX:XX:XX] RSSI: -XX
[BluetoothService] 🎯 Found target device: "cheesekeeper"!
[BluetoothService] 🔗 Attempting to connect to device: XX:XX:XX:XX:XX:XX
[BluetoothService] ✅ Connected successfully!
```

## 🔧 **Step 6: LED Status Indicators**

- **Fast blink (every 250ms):** ESP32 is advertising, waiting for connection
- **Slow blink (every 1000ms):** Connected but not authenticated
- **Solid ON:** Connected and authenticated
- **OFF:** Not connected

## 🎯 **Quick Checklist:**

- [ ] ESP32 has power and shows activity LED
- [ ] Code uploads successfully to ESP32
- [ ] Serial Monitor shows "BLE Advertising started!"
- [ ] ESP32 LED is blinking (indicating it's running)
- [ ] Flutter app can scan and finds other BLE devices
- [ ] Android phone has Bluetooth enabled and permissions granted

## 🆘 **If All Else Fails:**

1. **Try a different ESP32 board** - Hardware might be faulty
2. **Use Arduino IDE's BLE examples** - Test with built-in examples first
3. **Check ESP32 board package version** - Update to latest in Arduino IDE
4. **Try with a BLE scanner app** from Play Store to verify ESP32 is advertising

The most common issue is that the ESP32 code isn't running at all. Make sure you see serial output first!