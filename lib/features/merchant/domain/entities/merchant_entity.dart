class MerchantEntity {
  final int? id;
  final String name;
  final String? normalizedName;
  final String titleName;
  final String titleIcon;
  final int? categoryId;

  MerchantEntity({
    this.id,
    required this.name,
    this.normalizedName,
    required this.titleName,
    required this.titleIcon,
    this.categoryId,
  });
}
