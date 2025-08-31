class Transaction {
  final int? id;
  final String userId;
  final DateTime date;
  final double amount;
  final int paymentType;
  final int typeId;
  final String icon;
  final String title;
  final int categoryId;
  final String description;

  Transaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.paymentType,
    required this.typeId,
    required this.icon,
    required this.title,
    required this.categoryId,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'].toString()),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['payment_type'] as int? ?? 0,
      icon: json['icon']?.toString() ?? '',
      typeId: json['type_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'amount': typeId == 1 ? -amount.abs() : amount.abs(),
      'payment_type': paymentType,
      'type_id': typeId,
      'category_id': categoryId,
      'icon': icon,
      'title': title,
      'description': description,
    };
  }
}
