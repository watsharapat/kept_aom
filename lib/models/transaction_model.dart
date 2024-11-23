class Transaction {
  final String userId;
  final DateTime date;
  final double amount;
  final String via;
  final int typeId;
  final String title;
  final String description;

  Transaction({
    required this.userId,
    required this.date,
    required this.amount,
    required this.via,
    required this.typeId,
    required this.title,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['user_id'].toString(),
      date: DateTime.parse(json['date'].toString()),
      amount: json['amount'] is String
          ? double.tryParse(json['amount']) ?? 0.0
          : json['amount'] is int
              ? (json['amount'] as int).toDouble()
              : json['amount'] as double,
      via: json['via'].toString(),
      typeId: json['type_id'] is String
          ? int.tryParse(json['type_id']) ?? 1
          : json['type_id'] as int,
      title: json['title'].toString(),
      description: json['description'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'amount': typeId == 1 ? -amount.abs() : amount.abs(),
      'via': via,
      'type_id': typeId,
      'title': title,
      'description': description,
    };
  }
}
