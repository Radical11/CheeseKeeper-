import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _error;

  void _validateAndSend() {
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
    // Proceed with sending transaction
    setState(() => _error = null);
    // TODO: Send transaction logic
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
              decoration: const InputDecoration(
                labelText: "Recipient Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount (ETH)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateAndSend,
              child: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
