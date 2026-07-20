class CategoryEntity {
  final int categoryId;
  final String icon;
  final String name;
  final int typeId;
  final String userId;

  CategoryEntity({
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.icon,
    required this.typeId,
  });
}
