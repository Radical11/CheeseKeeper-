import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/setup_state.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user.dart';

class Step6Complete extends StatefulWidget {
  const Step6Complete({Key? key}) : super(key: key);

  @override
  State<Step6Complete> createState() => _Step6CompleteState();
}

class _Step6CompleteState extends State<Step6Complete> {
  bool _waiting = true;

  @override
  void initState() {
    super.initState();
    _finalizeSetup();
  }

  Future<void> _finalizeSetup() async {
    final setup = context.read<SetupState>();

    final user = User(
      publicKey: setup.publicKey ?? 'unknown',
      encryptedPrivateKey: setup.encryptedPrivateKey, // stored locally
      mnemonic: null,
    );

    await StorageService.saveUser(user);

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _waiting = false;
    });

    setup.clearEphemeral();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _waiting
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text("Finalizing setup..."),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 64),
                SizedBox(height: 24),
                Text(
                  "Setup Complete!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text("You can now log in to CheeseKeeper."),
              ],
            ),
    );
  }
}
