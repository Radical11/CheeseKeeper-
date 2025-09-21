import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class BluetoothService with ChangeNotifier {
  static const String deviceName = "SecureLink_Wallet";
  BluetoothConnection? _connection;
  BluetoothDevice? _device;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String? _lastStatusCode;
  String? get lastStatusCode => _lastStatusCode;

  // Singleton pattern
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  Future<bool> scanAndConnect() async {
    try {
      // Scan for paired devices
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      _device = devices.firstWhere((d) => d.name == deviceName,
          orElse: () => throw Exception("Device not found"));
      _connection = await BluetoothConnection.toAddress(_device!.address);
      _isConnected = true;
      notifyListeners();
      _listenForMessages();
      return true;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    _connection?.dispose();
    _isConnected = false;
    notifyListeners();
  }

  void _listenForMessages() {
    _connection?.input?.listen((Uint8List data) {
      final message = utf8.decode(data);
      try {
        final jsonMsg = json.decode(message);
        if (jsonMsg is Map && jsonMsg.containsKey('status')) {
          _lastStatusCode = jsonMsg['status'].toString();
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_connection != null && _isConnected) {
      final msg = json.encode(data);
      _connection!.output.add(utf8.encode(msg));
      await _connection!.output.allSent;
    }
  }

  // Retry logic for connection
  Future<bool> ensureConnected({int retries = 3}) async {
    int attempts = 0;
    while (!_isConnected && attempts < retries) {
      await scanAndConnect();
      attempts++;
      if (_isConnected) return true;
      await Future.delayed(Duration(seconds: 2));
    }
    return _isConnected;
  }
}
