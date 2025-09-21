import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/bluetooth_service.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetooth = Provider.of<BluetoothService>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          bluetooth.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
          color: bluetooth.isConnected ? Colors.greenAccent : Colors.redAccent,
        ),
        const SizedBox(width: 8),
        Text(
          bluetooth.isConnected ? "ESP32 Connected" : "ESP32 Disconnected",
          style: TextStyle(
            color: bluetooth.isConnected ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}