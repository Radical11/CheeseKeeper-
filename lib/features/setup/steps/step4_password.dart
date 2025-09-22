import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/state/setup_state.dart';
import '../../../core/services/crypto_service.dart';
import '../../../core/services/wallet_service.dart';

class Step4Password extends StatefulWidget {
  final VoidCallback? onNext;
  const Step4Password({Key? key, this.onNext}) : super(key: key);

  @override
  State<Step4Password> createState() => _Step4PasswordState();
}

class _Step4PasswordState extends State<Step4Password> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _created = false;

  Future<void> _validateAndCreate(BuildContext context) async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (Validators.validateNotEmpty(password) != null) {
      setState(() {
        _error = "Password required.";
        _created = false;
      });
      return;
    }
    if (!Validators.isStrongPassword(password)) {
      setState(() {
        _error =
            "Password must be at least 8 chars, include a number and letter.";
        _created = false;
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _error = "Passwords do not match.";
        _created = false;
      });
      return;
    }

    final setup = context.read<SetupState>();

    // Encrypt and store private key locally (no ESP32 required)
    if (setup.privateKeyPlain != null) {
      final enc = CryptoService.encryptAES(setup.privateKeyPlain!, password);
      final payload = json.encode({
        "ciphertext": enc['ciphertext'],
        "iv": enc['iv'],
      });
      setup.setEncryptedPrivateKey(payload);
      await WalletService.clearCachedPlainPrivateKey();
    }

    setup.setPassword(password);

    setState(() {
      _error = null;
      _created = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Create a strong password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            border: const OutlineInputBorder(),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Confirm Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _validateAndCreate(context),
          child: const Text("Create Password"),
        ),
        if (_created) ...[
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child:
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
          ),
        ],
      ],
    );
  }
}
