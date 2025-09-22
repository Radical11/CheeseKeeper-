import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/bluetooth_service.dart';
import 'core/state/setup_state.dart';
import 'app.dart';

import 'core/services/blockchain_service.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved RPC URL if present, so phones can talk to laptop Ganache
  final savedRpc = await StorageService.getString('rpc_url');
  if (savedRpc != null && savedRpc.isNotEmpty) {
    BlockchainService.configure(rpc: savedRpc);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothService()),
        ChangeNotifierProvider(create: (_) => SetupState()),
      ],
      child: const CheeseKeeperApp(),
    ),
  );
}
