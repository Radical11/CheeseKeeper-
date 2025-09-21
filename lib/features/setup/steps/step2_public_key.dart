import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class Step2PublicKey extends StatefulWidget {
  const Step2PublicKey({Key? key}) : super(key: key);

  @override
  State<Step2PublicKey> createState() => _Step2PublicKeyState();
}

class _Step2PublicKeyState extends State<Step2PublicKey> {
  final _controller = TextEditingController();
  String? _error;
  bool _saved = false;

  void _validateAndSave() {
    final value = _controller.text.trim();
    if (Validators.validateNotEmpty(value) != null) {
      setState(() {
        _error = "Public key required";
        _saved = false;
      });
      return;
    }
    if (Validators.isValidPublicKey(value)) {
      setState(() {
        _error = null;
        _saved = true;
      });
      // TODO: Save to local storage or state
    } else {
      setState(() {
        _error = "Invalid public key format";
        _saved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Enter your wallet public key",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Public Key",
            border: OutlineInputBorder(),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _validateAndSave,
          child: const Text("Add Public Key"),
        ),
        if (_saved)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child:
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          ),
      ],
    );
  }
}
