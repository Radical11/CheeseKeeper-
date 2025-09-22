import 'package:flutter/material.dart';
import '../../core/models/transaction.dart';
import '../../core/services/transaction_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<WalletTransaction> _txs = [];
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await TransactionService.list();
    setState(() { _txs = list; _loading = false; });
  }

  Future<void> _refresh() async {
    setState(() { _refreshing = true; });
    await TransactionService.refreshStatuses();
    await _load();
    setState(() { _refreshing = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _txs.isEmpty
            ? const Center(child: Text('No transactions yet'))
            : ListView.builder(
                itemCount: _txs.length,
                itemBuilder: (context, idx) {
                  final tx = _txs[idx];
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