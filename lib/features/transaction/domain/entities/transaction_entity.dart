class TransactionEntity {
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

  TransactionEntity({
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
}
