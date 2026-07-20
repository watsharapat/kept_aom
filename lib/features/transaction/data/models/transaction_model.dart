import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.amount,
    required super.paymentType,
    required super.typeId,
    required super.icon,
    required super.title,
    required super.categoryId,
    required super.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String? ?? '',
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
    final map = {
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
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      amount: entity.amount,
      paymentType: entity.paymentType,
      typeId: entity.typeId,
      icon: entity.icon,
      title: entity.title,
      categoryId: entity.categoryId,
      description: entity.description,
    );
  }
}
