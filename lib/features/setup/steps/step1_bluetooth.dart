import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/bluetooth_service.dart';

class Step1Bluetooth extends StatefulWidget {
  final VoidCallback? onNext;
  const Step1Bluetooth({Key? key, this.onNext}) : super(key: key);

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
        // Show error message if there is one
        if (bluetooth.lastError != null && !bluetooth.isConnected) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Connection Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bluetooth.lastError!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
        if (bluetooth.isConnected) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onNext,
          child: const Text('Skip (demo mode without ESP32)'),
        ),
        // Debug info button
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Debug Info'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Connected: ${bluetooth.isConnected}'),
                      Text('Last Error: ${bluetooth.lastError ?? "None"}'),
                      Text('Last Response: ${bluetooth.lastResponse ?? "None"}'),
                      Text('Last Status Code: ${bluetooth.lastStatusCode ?? "None"}'),
                      const SizedBox(height: 16),
                      const Text('Check your console (flutter logs) for detailed debugging information.',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Show Debug Info', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
