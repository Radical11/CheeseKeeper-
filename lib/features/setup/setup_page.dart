import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'steps/step1_bluetooth.dart';
import 'steps/step2_public_key.dart';
import 'steps/step3_private_key.dart';
import 'steps/step4_password.dart';
import 'steps/step5_mnemonic.dart';
import 'steps/step6_complete.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/bluetooth_service.dart';
import '../../core/state/setup_state.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _clearPreviousData();
  }

  Future<void> _clearPreviousData() async {
    // Clear local user data
    await StorageService.removeUser();
    
    // Clear setup state
    final setupState = context.read<SetupState>();
    setupState.clearEphemeral();
    setupState.publicKey = null; // Also clear public key
    
    // Send clear command to ESP32 if connected
    try {
      final ble = context.read<BluetoothService>();
      if (ble.isConnected || await ble.ensureConnected(retries: 1)) {
        await ble.sendJson({"command": "clearUser"});
      }
    } catch (_) {
      // Ignore if ESP32 is not connected - user can still set up
    }
  }

  List<Widget> get _steps => [
    Step1Bluetooth(onNext: _nextStep),
    Step2PublicKey(onNext: _nextStep),
    Step3PrivateKey(onNext: _nextStep),
    Step4Password(onNext: _nextStep),
    Step5Mnemonic(onNext: _nextStep),
    const Step6Complete(),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheeseKeeper Setup'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _steps[_currentStep],
      ),
      // Remove global next FAB to prevent skipping
      floatingActionButton: null,
    );
  }
}
