import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/setup_state.dart';
import '../../../core/services/wallet_service.dart';

class Step2PublicKey extends StatefulWidget {
  final VoidCallback? onNext;
  const Step2PublicKey({Key? key, this.onNext}) : super(key: key);

  @override
  State<Step2PublicKey> createState() => _Step2PublicKeyState();
}

class _Step2PublicKeyState extends State<Step2PublicKey> {
  String _mode = 'import'; // 'import' or 'generate'
  bool _busy = false;
  String? _address;
  String? _error;
  final _pkController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _autoGenerate() async {
    setState(() { _busy = true; _error = null; });
    try {
      final privHex = await WalletService.generatePrivateKeyHex();
      final addr = await WalletService.deriveAddressHex(privHex);
      await WalletService.cachePlainPrivateKey(privHex);
      final setup = context.read<SetupState>();
      setup.setPrivateKey(privHex);
      setup.setPublicKey(addr);
      setState(() { _address = addr; });
    } catch (e) {
      setState(() { _error = 'Failed to generate wallet: ${e.toString()}'; });
    } finally {
      setState(() { _busy = false; });
    }
  }

  Future<void> _importGanachePk() async {
    final raw = _pkController.text.trim();
    if (raw.isEmpty) {
      setState(() { _error = 'Enter a Ganache private key (hex)'; });
      return;
    }
    final privHex = raw.startsWith('0x') ? raw.substring(2) : raw;
    if (privHex.length != 64) {
      setState(() { _error = 'Private key must be 64 hex chars (optionally prefixed 0x)'; });
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final addr = await WalletService.deriveAddressHex(privHex);
      await WalletService.cachePlainPrivateKey(privHex);
      final setup = context.read<SetupState>();
      setup.setPrivateKey(privHex);
      setup.setPublicKey(addr);
      setState(() { _address = addr; });
    } catch (e) {
      setState(() { _error = 'Failed to derive address: ${e.toString()}'; });
    } finally {
      setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose wallet source',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: [_mode == 'import', _mode == 'generate'],
            onPressed: (index) {
              setState(() { _mode = index == 0 ? 'import' : 'generate'; _address = null; _error = null; });
            },
            borderRadius: BorderRadius.circular(12),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Use Ganache key')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Generate new')),
            ],
          ),
          const SizedBox(height: 20),

          if (_mode == 'import') ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Paste Ganache private key (0x...)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pkController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ganache Private Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tip: Your Ganache private key is\n0x9594140aaf5d2910015daca8b9f9c5b8dd9dc6fbec2d6412a7f99f1547c448c1',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _pkController.text = '0x9594140aaf5d2910015daca8b9f9c5b8dd9dc6fbec2d6412a7f99f1547c448c1';
                    },
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Fill Your Key', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _busy ? null : _importGanachePk,
              icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.key),
              label: Text(_busy ? 'Importing...' : 'Import and derive address'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _busy ? null : _autoGenerate,
              icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.auto_awesome),
              label: Text(_busy ? 'Generating...' : 'Generate wallet'),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.redAccent)),
          ],

          const SizedBox(height: 16),
          if (_address != null) ...[
            const Text('Your public address (EIP-55):'),
            const SizedBox(height: 8),
            SelectableText(
              _address!,
              style: const TextStyle(fontFamily: 'monospace'),
              textAlign: TextAlign.center,
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
