import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class Step4Password extends StatefulWidget {
  const Step4Password({Key? key}) : super(key: key);

  @override
  State<Step4Password> createState() => _Step4PasswordState();
}

class _Step4PasswordState extends State<Step4Password> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _created = false;

  void _validateAndCreate() {
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
    // TODO: Send password to ESP32 via Bluetooth for storage
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
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
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
          onPressed: _validateAndCreate,
          child: const Text("Create Password"),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ),
        if (_created)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child:
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          ),
      ],
    );
  }
}
