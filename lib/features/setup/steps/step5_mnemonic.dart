import 'package:flutter/material.dart';
// import 'package:bip39/bip39.dart' as bip39;
import '../../../core/utils/validators.dart';
import '../../../core/utils/encryption.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user.dart';

class Step5Mnemonic extends StatefulWidget {
  final VoidCallback? onNext;
  const Step5Mnemonic({Key? key, this.onNext}) : super(key: key);

  @override
  State<Step5Mnemonic> createState() => _Step5MnemonicState();
}

class _Step5MnemonicState extends State<Step5Mnemonic> {
  final _controller = TextEditingController();
  String? _error;
  bool _saved = false;
  bool _confirmedBackup = false;

  void _validateAndSave() async {
    final phrase = _controller.text.trim();

    if (Validators.validateNotEmpty(phrase) != null) {
      setState(() => _error = "Mnemonic required.");
      return;
    }
    // Optionally, add BIP39 validation here

    final password = ""; // Retrieve or prompt for the user's password
    final encryptedMnemonic = EncryptionUtil.encryptAES(phrase, password);

    // Update user in storage
    final user = await StorageService.loadUser();
    if (user != null) {
      final updatedUser = User(
        publicKey: user.publicKey,
        encryptedPrivateKey: user.encryptedPrivateKey,
        mnemonic: encryptedMnemonic,
      );
      await StorageService.saveUser(updatedUser);
    }

    // Proceed with saving mnemonic
    setState(() { _error = null; _saved = true; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Enter your 12-word recovery phrase",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Mnemonic Phrase",
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _confirmedBackup,
            onChanged: (val) => setState(() => _confirmedBackup = val ?? false),
            title: const Text("I have safely backed up my recovery phrase"),
          ),
          ElevatedButton(
            onPressed: _validateAndSave,
            child: const Text("Save Recovery Phrase"),
          ),
          if (_saved) ...[
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
      ),
    );
  }
}
