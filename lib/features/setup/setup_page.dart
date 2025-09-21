import 'package:flutter/material.dart';
import 'steps/step1_bluetooth.dart';
import 'steps/step2_public_key.dart';
import 'steps/step3_private_key.dart';
import 'steps/step4_password.dart';
import 'steps/step5_mnemonic.dart';
import 'steps/step6_complete.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _currentStep = 0;

  final List<Widget> _steps = const [
    Step1Bluetooth(),
    Step2PublicKey(),
    Step3PrivateKey(),
    Step4Password(),
    Step5Mnemonic(),
    Step6Complete(),
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

  Future<void> _saveUser() async {
    // Assuming you have a user object to save
    final user = User(
      publicKey: 'yourPublicKey',
      encryptedPrivateKey: 'yourEncryptedPrivateKey',
      mnemonic: 'yourEncryptedMnemonic',
    );
    await StorageService.saveUser(user);
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
      floatingActionButton: _currentStep < _steps.length - 1
          ? FloatingActionButton(
              onPressed: () {
                if (_currentStep == _steps.length - 2) {
                  _saveUser();
                }
                _nextStep();
              },
              child: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}
