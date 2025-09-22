import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BluetoothService with ChangeNotifier {
  // Debug logging
  void _log(String message) {
    print('[BluetoothService] $message');
  }

  static String obfuscate(String input) {
    const int key = 0xAB;
    final codeUnits = input.codeUnits.map((c) => c ^ key).toList();
    return String.fromCharCodes(codeUnits);
  }
  // Match your ESP32 BLE name exactly
  static const String deviceName = "cheesekeeper";

  // UUIDs must match your ESP32 firmware
  static final Guid serviceUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  static final Guid cmdCharUuid = Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  static final Guid rspCharUuid = Guid("beb5483f-36e1-4688-b7f5-ea07361b26a8");

  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdChar;
  BluetoothCharacteristic? _rspChar;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _lastStatusCode;
  String? get lastStatusCode => _lastStatusCode;

  String? _lastResponse;
  String? get lastResponse => _lastResponse;

  String? _lastError;
  String? get lastError => _lastError;

  StreamSubscription<List<int>>? _notifySub;

  // Singleton
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) {
      _log('Not Android platform, permissions not needed');
      return true;
    }

    // Determine SDK version to decide if location is needed
    final info = await DeviceInfoPlugin().androidInfo;
    final sdk = info.version.sdkInt;
    _log('Android SDK version: $sdk');

    final perms = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];

    // On Android <= 30, location permission is required for scanning
    if (sdk <= 30) {
      perms.add(Permission.locationWhenInUse);
      _log('Added location permission for SDK <= 30');
    }

    _log('Requesting permissions: ${perms.map((p) => p.toString()).join(', ')}');
    final statuses = await perms.request();
    
    for (final perm in perms) {
      final status = statuses[perm];
      _log('Permission $perm: $status');
      if (status != PermissionStatus.granted) {
        _lastError = 'Permission denied: $perm';
        _log('❌ Permission denied: $perm');
      }
    }
    
    final allGranted = statuses.values.every((s) => s.isGranted);
    _log(allGranted ? '✅ All permissions granted' : '❌ Some permissions denied');
    return allGranted;
  }

  Future<bool> scanAndConnect() async {
    try {
      _lastError = null;
      _log('🔍 Starting scan and connect process...');
      
      if (!await _ensurePermissions()) {
        _lastError = 'Permissions not granted';
        _log('❌ Permissions not granted');
        return false;
      }

      // Check if Bluetooth is enabled
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _lastError = 'Bluetooth not supported on this device';
        _log('❌ Bluetooth not supported');
        return false;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      _log('Bluetooth adapter state: $adapterState');
      if (adapterState != BluetoothAdapterState.on) {
        _lastError = 'Bluetooth is not enabled. Current state: $adapterState';
        _log('❌ Bluetooth not enabled: $adapterState');
        return false;
      }

      // If already connected, shortcut
      if (_isConnected && _device != null) {
        _log('✅ Already connected to device');
        return true;
      }

      _log('🔎 Starting BLE scan for device: "$deviceName"');
      
      // Start scan and wait for device by name
      final completer = Completer<BluetoothDevice?>();
      int devicesFound = 0;
      final sub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          devicesFound++;
          final platformName = r.device.platformName;
          final advName = r.advertisementData.advName;
          final name = platformName.isNotEmpty ? platformName : advName;
          
          _log('📡 Found device: "$name" (platform: "$platformName", adv: "$advName") [${r.device.remoteId}] RSSI: ${r.rssi}');
          
          if (name == deviceName) {
            _log('🎯 Found target device: "$name"!');
            completer.complete(r.device);
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
      _device = await completer.future.timeout(const Duration(seconds: 9), onTimeout: () {
        _log('⏰ Scan timeout - found $devicesFound devices total');
        return null;
      });
      await FlutterBluePlus.stopScan();
      await sub.cancel();

      if (_device == null) {
        _lastError = 'Device "$deviceName" not found after scanning $devicesFound devices';
        _log('❌ Device not found after scanning $devicesFound devices');
        throw Exception(_lastError!);
      }

      _log('🔗 Attempting to connect to device: ${_device!.remoteId}');
      
      // Connect
      await _device!.connect(timeout: const Duration(seconds: 12), autoConnect: false);
      _isConnected = true;
      _log('✅ Connected successfully!');
      notifyListeners();

      _log('🔍 Discovering services...');
      // Discover services/characteristics
      final services = await _device!.discoverServices();
      _log('Found ${services.length} services');
      
      for (final service in services) {
        _log('  Service: ${service.uuid}');
        for (final char in service.characteristics) {
          _log('    Characteristic: ${char.uuid} (properties: ${char.properties})');
        }
      }
      
      final svc = services.firstWhere((s) => s.uuid == serviceUuid, orElse: () {
        _lastError = 'Service $serviceUuid not found';
        _log('❌ Service not found: $serviceUuid');
        throw Exception(_lastError!);
      });
      _log('✅ Found target service: ${svc.uuid}');
      
      _cmdChar = svc.characteristics.firstWhere((c) => c.uuid == cmdCharUuid, orElse: () {
        _lastError = 'Command characteristic $cmdCharUuid not found';
        _log('❌ CMD characteristic not found: $cmdCharUuid');
        throw Exception(_lastError!);
      });
      _log('✅ Found command characteristic: ${_cmdChar!.uuid}');
      
      _rspChar = svc.characteristics.firstWhere((c) => c.uuid == rspCharUuid, orElse: () {
        _lastError = 'Response characteristic $rspCharUuid not found';
        _log('❌ RSP characteristic not found: $rspCharUuid');
        throw Exception(_lastError!);
      });
      _log('✅ Found response characteristic: ${_rspChar!.uuid}');

      // Subscribe to notifications
      _log('📡 Setting up notifications...');
      await _rspChar!.setNotifyValue(true);
      _notifySub?.cancel();
      _notifySub = _rspChar!.onValueReceived.listen((data) {
        try {
          final msg = utf8.decode(data);
          _log('📨 Received notification: $msg');
          _lastResponse = msg; // Store raw response
          
          try {
            final jsonMsg = json.decode(msg);
            if (jsonMsg is Map && jsonMsg.containsKey('status')) {
              _lastStatusCode = jsonMsg['status'].toString();
              _log('📊 Status code: ${_lastStatusCode}');
            }
          } catch (e) {
            _log('⚠️ Failed to parse JSON response: $e');
            // Not JSON, that's fine - we have the raw response
          }
          
          notifyListeners();
        } catch (e) {
          _log('❌ Failed to decode notification data: $e');
        }
      });
      _log('✅ Notifications set up successfully');

      _log('🎉 Connection process completed successfully!');
      return true;
    } catch (e) {
      _isConnected = false;
      _lastError = 'Connection failed: $e';
      _log('❌ Connection failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _rspChar?.setNotifyValue(false);
    } catch (_) {}
    await _notifySub?.cancel();
    _notifySub = null;
    try {
      await _device?.disconnect();
    } catch (_) {}
    _cmdChar = null;
    _rspChar = null;
    _device = null;
    _isConnected = false;
    notifyListeners();
  }

  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_cmdChar == null || !_isConnected) {
      _log('❌ Cannot send - not connected or characteristic null');
      return;
    }
    final jsonStr = json.encode(data);
    final payload = utf8.encode(jsonStr);
    _log('📤 Sending command: $jsonStr');
    await _cmdChar!.write(payload, withoutResponse: false);
  }

  Future<bool> ensureConnected({int retries = 3}) async {
    int attempts = 0;
    while (!_isConnected && attempts < retries) {
      await scanAndConnect();
      attempts++;
      if (_isConnected) return true;
      await Future.delayed(const Duration(seconds: 2));
    }
    return _isConnected;
  }
}
