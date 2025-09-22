import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user.dart';
import '../../core/services/blockchain_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _loading = true;
  bool _savingRpc = false;
  final _rpcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.loadUser();
    final savedRpc = await StorageService.getString('rpc_url');
    if (savedRpc != null && savedRpc.isNotEmpty) {
      BlockchainService.configure(rpc: savedRpc);
      _rpcController.text = savedRpc;
    } else {
      _rpcController.text = BlockchainService.rpcUrl;
    }
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await StorageService.removeUser();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: Text('No user data found.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              title: 'RPC URL (Ganache)',
              icon: Icons.settings_ethernet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _rpcController,
                    decoration: const InputDecoration(
                      labelText: 'http://127.0.0.1:8545',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savingRpc
                          ? null
                          : () async {
                              setState(() => _savingRpc = true);
                              final rpc = _rpcController.text.trim();
                              await StorageService.saveString('rpc_url', rpc);
                              BlockchainService.configure(rpc: rpc);
                              setState(() => _savingRpc = false);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RPC URL saved')));
                            },
                      icon: _savingRpc
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.save, size: 18),
                      label: Text(_savingRpc ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(
              title: 'Public Address',
              icon: Icons.key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _user!.publicKey,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _user!.publicKey));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Public key copied!')));
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Public Key'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
