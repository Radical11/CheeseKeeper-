import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/bluetooth_service.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BluetoothService(),
      child: const CheeseKeeperApp(),
    ),
  );
}