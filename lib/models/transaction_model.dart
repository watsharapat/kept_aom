class Transaction {
  final String? id;
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
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      date: DateTime.parse(json['date'].toString()),
      amount: json['amount'] is String
          ? double.tryParse(json['amount']) ?? 0.0
          : json['amount'] is int
              ? (json['amount'] as int).toDouble()
              : json['amount'] as double,
      paymentType: int.parse(json['payment_type']),
      icon: json['icon'].toString(),
      typeId: int.parse(json['type_id']),
      categoryId: int.parse(json['payment_type']),
      title: json['title'].toString(),
      description: json['description'].toString(),
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
