import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/encryption.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _showPrivateKey = false;
  bool _showPassword = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.loadUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await StorageService.removeUser();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data found.')),
      );
    }

    final password = "your_password"; // Retrieve the password securely
    final decryptedPrivateKey =
        EncryptionUtil.decryptAES(_user!.encryptedPrivateKey!, password);
    final decryptedMnemonic =
        EncryptionUtil.decryptAES(_user!.mnemonic!, password);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Public Key:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: SelectableText(_user!.publicKey)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _user!.publicKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Public key copied!")));
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Private Key:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _showPrivateKey
                        ? decryptedPrivateKey
                        : "----------------------",
                    style: const TextStyle(letterSpacing: 2),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _showPrivateKey = !_showPrivateKey),
                  child: Text(_showPrivateKey ? "Hide" : "Show"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Password:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _showPassword ? "Encrypted" : "--------",
                    style: const TextStyle(letterSpacing: 2),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  child: Text(_showPassword ? "Hide" : "Show Password"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Show mnemonic in a secure dialog
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Recovery Mnemonic"),
                    content: Text(decryptedMnemonic),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Show Recovery Mnemonic"),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
