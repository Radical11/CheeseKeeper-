import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/storage_service.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  String? walletAddress;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    final user = await StorageService.loadUser();
    setState(() {
      walletAddress = user?.publicKey ?? 'No wallet address found';
      loading = false;
    });
  }

  void _copyToClipboard() {
    if (walletAddress != null && walletAddress!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet address copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Crypto')),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your Wallet Address:", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141833),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00D4FF), width: 1),
                    ),
                    child: SelectableText(
                      walletAddress ?? 'Loading...', 
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'monospace'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (walletAddress != null && walletAddress!.startsWith('0x'))
                    QrImageView(
                      data: walletAddress!,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: walletAddress != null ? _copyToClipboard : null,
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Address"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Share this QR code or address to receive crypto payments",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
