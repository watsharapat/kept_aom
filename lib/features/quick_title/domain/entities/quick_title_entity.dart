class QuickTitleEntity {
  final int? id;
  final String icon;
  final String? userId;
  final String title;
  final int typeId;
  final int? categoryId;
  final int? displayOrder;

  QuickTitleEntity({
    this.id,
    required this.icon,
    this.userId,
    required this.typeId,
    required this.title,
    this.categoryId,
    this.displayOrder,
  });
}
