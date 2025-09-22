import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user.dart';
import '../../core/services/blockchain_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> _fundWallet(BuildContext context) async {
    if (_user == null) return;
    
    try {
      // Send ETH from first Ganache account to user's wallet
      final rpcUrl = BlockchainService.rpcUrl;
      print('🏦 Funding wallet: ${_user!.publicKey}');
      print('🔗 Using RPC: $rpcUrl');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requesting test ETH...'), duration: Duration(seconds: 2)),
      );
      
      final body = json.encode({
        'jsonrpc': '2.0',
        'method': 'eth_sendTransaction',
        'params': [
          {
            'from': '0x0f3580b48bc561462c1187cfaa6e6461aca491eb', // First Ganache account
            'to': _user!.publicKey,
            'value': '0x${(BigInt.from(5) * BigInt.from(10).pow(18)).toRadixString(16)}', // 5 ETH
          }
        ],
        'id': 1,
      });
      
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      final jsonResp = json.decode(response.body);
      if (jsonResp['error'] != null) {
        throw Exception('RPC Error: ${jsonResp['error']['message']}');
      }
      
      if (jsonResp['result'] != null) {
        final txHash = jsonResp['result'] as String;
        print('✅ Funding transaction: $txHash');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Test ETH sent! TX: ${txHash.substring(0, 10)}...')),
        );
      } else {
        throw Exception('Unexpected response from RPC server');
      }
      
    } catch (e) {
      print('❌ Funding failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to get test ETH: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: SingleChildScrollView(
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
                      labelText: 'RPC URL',
                      hintText: 'http://172.16.0.2:42654 or http://172.18.230.189:42654',
                      border: OutlineInputBorder(),
                      helperText: 'Use your computer\'s IP address, not localhost',
                      helperMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Network Setup Tips:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Use your computer\'s IP address (not localhost)\n'
                            '• Try: http://172.16.0.2:42654\n'
                            '• Or: http://172.18.230.189:42654\n'
                            '• Make sure Ganache is running on port 42654\n'
                            '• Check firewall settings if connection fails',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _user!.publicKey));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Public key copied!')));
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Address'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _fundWallet(context);
                          },
                          icon: const Icon(Icons.account_balance_wallet, size: 16),
                          label: const Text('Get Test ETH'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(
              title: 'Account',
              icon: Icons.logout,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32), // Extra bottom padding for accessibility
          ],
        ),
      ),
    );
  }
}
