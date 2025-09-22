import 'package:flutter/material.dart';
import '../../widgets/connection_status.dart';
import './send_page.dart';
import './receive_page.dart';
import '../../core/models/transaction.dart';
import '../../core/services/blockchain_service.dart';
import '../../core/services/transaction_service.dart';
import '../../core/services/storage_service.dart';
import 'package:web3dart/web3dart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? _balanceEth;
  List<WalletTransaction> _recent = [];
  String? _address;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Load user address
      final user = await StorageService.loadUser();
      final addr = user?.publicKey;
      if (addr == null) {
        setState(() { _loading = false; });
        return;
      }
      _address = addr;

      // Load balance
      final ethAddr = EthereumAddress.fromHex(addr);
      final balWei = await BlockchainService.getBalance(ethAddr);
      final balEth = balWei.getValueInUnit(EtherUnit.ether).toDouble();

      // Load recent tx (last 5 saved)
      final all = await TransactionService.list();
      final recent = all.take(5).toList();

      setState(() {
        _balanceEth = balEth;
        _recent = recent;
        _loading = false;
      });
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ConnectionStatus(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portfolio Balance
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Portfolio Balance",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _balanceEth == null ? "-" : "${_balanceEth!.toStringAsFixed(6)} ETH",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _address == null ? "" : _address!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
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
                const _QuickActionButton(icon: Icons.shopping_cart, label: "Buy", onTap: null),
                const _QuickActionButton(icon: Icons.swap_horiz, label: "Swap", onTap: null),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Transactions
            Text(
              "Recent Transactions",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final tx = _recent[idx];
                final statusColor = tx.status == "Success"
                    ? Colors.greenAccent
                    : tx.status == "Pending"
                        ? Colors.orangeAccent
                        : Colors.redAccent;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.15),
                      child: Icon(
                        tx.status == "Success"
                            ? Icons.check_circle
                            : tx.status == "Pending"
                                ? Icons.hourglass_empty
                                : Icons.cancel,
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      "To: ${tx.to}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      "${tx.amount} ETH • ${tx.timestamp}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        tx.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              },
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
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap != null 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: onTap != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: onTap != null
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onTap != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
