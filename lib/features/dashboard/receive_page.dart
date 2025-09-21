import 'package:flutter/material.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual wallet address
    final walletAddress = "0xYourWalletAddressHere";

    return Scaffold(
      appBar: AppBar(title: const Text('Receive Crypto')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your Wallet Address:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            SelectableText(walletAddress, style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 24),
            // TODO: Add QR code widget here
            ElevatedButton(
              onPressed: () {
                // TODO: Copy address to clipboard
              },
              child: const Text("Copy Address"),
            ),
          ],
        ),
      ),
    );
  }
}