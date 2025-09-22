class WalletTransaction {
  final String hash;
  final String from;
  final String to;
  final double amount; // ETH
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

  WalletTransaction copyWith({
    String? hash,
    String? from,
    String? to,
    double? amount,
    DateTime? timestamp,
    String? status,
  }) => WalletTransaction(
        hash: hash ?? this.hash,
        from: from ?? this.from,
        to: to ?? this.to,
        amount: amount ?? this.amount,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'hash': hash,
        'from': from,
        'to': to,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory WalletTransaction.fromMap(Map<String, dynamic> map) => WalletTransaction(
        hash: map['hash'],
        from: map['from'],
        to: map['to'],
        amount: (map['amount'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp']),
        status: map['status'],
      );
}
