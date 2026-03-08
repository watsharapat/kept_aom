class Merchant {
  final int? id;
  final String name;
  final String? normalizedName;
  final String titleName;
  final String titleIcon;
  final int? categoryId;

  Merchant({
    this.id,
    required this.name,
    this.normalizedName,
    required this.titleName,
    required this.titleIcon,
    this.categoryId,
  });
  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as int?,
      name: json['name'] as String,
      normalizedName: json['normalizedName'] as String?,
      titleName: json['title_name'] as String,
      titleIcon: json['title_icon'] as String,
      categoryId: json['category_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'titleName': titleName,
      'titleIcon': titleIcon,
      'categoryId': categoryId,
    };
  }
}
