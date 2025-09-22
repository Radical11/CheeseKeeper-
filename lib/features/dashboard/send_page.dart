import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../core/utils/validators.dart';
import '../../core/services/blockchain_service.dart';
import '../../core/services/storage_service.dart';
import 'dart:convert';
import '../../core/services/crypto_service.dart';
import 'package:web3dart/web3dart.dart';
import '../../core/services/transaction_service.dart';
import '../../core/models/transaction.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _sending = false;

  Future<void> _scanAddress() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        setState(() => _addressController.text = result.rawContent.trim());
      }
    } catch (_) {}
  }

  Future<void> _validateAndSend() async {
    final address = _addressController.text.trim();
    final amount = _amountController.text.trim();

    if (Validators.validateNotEmpty(address) != null) {
      setState(() => _error = "Recipient address required.");
      return;
    }
    if (!Validators.isValidPublicKey(address)) {
      setState(() => _error = "Invalid address format.");
      return;
    }
    if (Validators.validateNotEmpty(amount) != null) {
      setState(() => _error = "Amount required.");
      return;
    }
    if (double.tryParse(amount) == null || double.parse(amount) <= 0) {
      setState(() => _error = "Enter a valid amount.");
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = "Password required to sign transaction.");
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      // Load user for encrypted private key
      final user = await StorageService.loadUser();
      if (user == null || user.encryptedPrivateKey == null) {
        setState(() => _error = 'Wallet not initialized.');
        return;
      }
      final enc = json.decode(user.encryptedPrivateKey!);
      final privHex = CryptoService.decryptAES(enc['ciphertext'], enc['iv'], password);
      if (privHex == null) {
        setState(() => _error = 'Incorrect password.');
        return;
      }

      final creds = EthPrivateKey.fromHex(privHex);
      final to = EthereumAddress.fromHex(address);
      // Convert amount to EtherAmount properly (EtherUnit.ether already handles the wei conversion)
      final ethAmount = EtherAmount.fromUnitAndValue(EtherUnit.ether, double.parse(amount));

      final txHash = await BlockchainService.sendEth(
        credentials: creds,
        to: to,
        amount: ethAmount,
      );

      // Persist in local history for demo
      final fromAddr = (await creds.extractAddress()).hexEip55;
      await TransactionService.add(WalletTransaction(
        hash: txHash,
        from: fromAddr,
        to: address,
        amount: double.parse(amount),
        timestamp: DateTime.now(),
        status: 'Pending',
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction sent: $txHash')),
      );
      _amountController.clear();

    } catch (e) {
      setState(() => _error = "Error sending transaction: ${e.toString()}");
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Crypto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Recipient Address",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanAddress,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount (ETH)",
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _validateAndSend,
              child: _sending 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      Text("Sending...")
                    ],
                  )
                : const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
