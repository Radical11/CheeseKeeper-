import 'package:flutter/material.dart';
import '../../widgets/connection_status.dart';
import './send_page.dart';
import './receive_page.dart';
import 'history_page.dart';
import '../../core/models/transaction.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final double balance = 2.345; // ETH
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
      appBar: AppBar(
        title: const Text('CheeseKeeper Dashboard'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ConnectionStatus(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Portfolio Balance
            Card(
              color: const Color(0xFF0A0E27),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      "Portfolio Balance",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$balance ETH",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickActionButton(
                  icon: Icons.send,
                  label: "Send",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendPage()),
                  ),
                ),
                _QuickActionButton(
                  icon: Icons.call_received,
                  label: "Receive",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceivePage()),
                  ),
                ),
                _QuickActionButton(
                    icon: Icons.shopping_cart, label: "Buy", onTap: () {}),
                _QuickActionButton(
                    icon: Icons.swap_horiz, label: "Swap", onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Transactions
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, idx) {
                  final tx = transactions[idx];
                  return Card(
                    color: const Color(0xFF151A30),
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
                      title: Text("To: ${tx.to}",
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text("${tx.amount} ETH • ${tx.timestamp}",
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text(tx.status,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          mini: true,
          backgroundColor: const Color(0xFF00D4FF),
          onPressed: onTap,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
