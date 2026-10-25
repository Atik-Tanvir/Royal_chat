class WalletTransaction {
  final String id;
  final String userId;
  final String type; // 'recharge', 'withdrawal', 'conversion', 'gift_sent', 'gift_received', 'daily_reward'
  final String title;
  final double amount;
  final String currency; // 'coin', 'gem', 'usd'
  final String status; // 'Pending', 'Completed', 'Approved', 'Rejected'
  final String gateway;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'amount': amount,
      'currency': currency,
      'status': status,
      'gateway': gateway,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String? ?? 'TX-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? '',
      type: json['type'] as String? ?? 'recharge',
      title: json['title'] as String? ?? 'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'coin',
      status: json['status'] as String? ?? 'Completed',
      gateway: json['gateway'] as String? ?? 'In-App',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
