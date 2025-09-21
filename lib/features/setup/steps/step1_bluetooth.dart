import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/bluetooth_service.dart';

class Step1Bluetooth extends StatefulWidget {
  const Step1Bluetooth({Key? key}) : super(key: key);

  @override
  State<Step1Bluetooth> createState() => _Step1BluetoothState();
}

class _Step1BluetoothState extends State<Step1Bluetooth> {
  bool _connecting = false;
  String _status = "Not connected";

  Future<void> _connectToESP32(BuildContext context) async {
    setState(() {
      _connecting = true;
      _status = "Scanning for ESP32...";
    });

    final bluetooth = Provider.of<BluetoothService>(context, listen: false);
    final success = await bluetooth.scanAndConnect();

    setState(() {
      _connecting = false;
      _status = success ? "Connected to ESP32!" : "Connection failed. Try again.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetooth = Provider.of<BluetoothService>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          bluetooth.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
          color: bluetooth.isConnected ? Colors.greenAccent : Colors.redAccent,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          bluetooth.isConnected ? "Connected to ESP32!" : _status,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _connecting || bluetooth.isConnected
              ? null
              : () => _connectToESP32(context),
          child: _connecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Connect to ESP32'),
        ),
        if (bluetooth.isConnected)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          ),
      ],
    );
  }
}