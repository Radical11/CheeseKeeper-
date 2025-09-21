class WalletTransaction {
  final String hash;
  final String from;
  final String to;
  final double amount;
  final DateTime timestamp;
  final String status; // e.g., "Success", "Pending", "Failed"

  WalletTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
    required this.status,
  });
}