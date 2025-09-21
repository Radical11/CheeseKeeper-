import 'package:flutter/material.dart';
import '../../core/models/transaction.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock transaction data
    final List<WalletTransaction> transactions = [
      WalletTransaction(
        hash: "0xabc123...",
        from: "0x1111...aaaa",
        to: "0x2222...bbbb",
        amount: 0.5,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        status: "Success",
      ),
      WalletTransaction(
        hash: "0xdef456...",
        from: "0x1111...aaaa",
        to: "0x3333...cccc",
        amount: 1.2,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: "Pending",
      ),
      WalletTransaction(
        hash: "0xghi789...",
        from: "0x1111...aaaa",
        to: "0x4444...dddd",
        amount: 0.3,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: "Failed",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, idx) {
          final tx = transactions[idx];
          return Card(
            color: const Color(0xFF151A30),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                tx.status == "Success"
                    ? Icons.check_circle
                    : tx.status == "Pending"
                        ? Icons.hourglass_empty
                        : Icons.cancel,
                color: tx.status == "Success"
                    ? Colors.greenAccent
                    : tx.status == "Pending"
                        ? Colors.orangeAccent
                        : Colors.redAccent,
              ),
              title: Text(
                "To: ${tx.to}",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${tx.amount} ETH • ${_formatTimestamp(tx.timestamp)}",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                tx.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }
}