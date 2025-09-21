import 'package:flutter/material.dart';
import '../../../core/utils/encryption.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user.dart';

class Step3PrivateKey extends StatefulWidget {
  const Step3PrivateKey({Key? key}) : super(key: key);

  @override
  State<Step3PrivateKey> createState() => _Step3PrivateKeyState();
}

class _Step3PrivateKeyState extends State<Step3PrivateKey> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _secured = false;

  void _processPrivateKey() async {
    final value = _controller.text.trim();
    if (value.isEmpty || value.length < 32) {
      setState(() {
        _error = "Invalid private key";
        _secured = false;
      });
      return;
    }
    final password = "your_password"; // Get the password from a secure place
    final privateKey = value;
    final encryptedPrivateKey = EncryptionUtil.encryptAES(privateKey, password);

    // TODO: Replace this with the actual public key from previous step or state
    final publicKey = "your_public_key"; // Placeholder value

    // Save user with encrypted private key
    final user = User(
      publicKey: publicKey,
      encryptedPrivateKey: encryptedPrivateKey,
      mnemonic: null,
    );
    await StorageService.saveUser(user);

    setState(() {
      _error = null;
      _secured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Enter your private key",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: "Private Key",
            border: const OutlineInputBorder(),
            errorText: _error,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _processPrivateKey,
          child: const Text("Secure Private Key"),
        ),
        if (_secured)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              "Private key secured",
              style: TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
