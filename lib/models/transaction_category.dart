class TransactionCategory {
  final int categoryId;
  final String icon;
  final String name;
  final int typeId;
  final String userId;

  TransactionCategory({
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.icon,
    required this.typeId,
  });
  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      userId: json['user_id'].toString(),
      name: json['name'].toString(),
      categoryId: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] as int,
      icon: json['icon'] is String ? json['icon'] : json['icon'].toString(),
      typeId: json['type'] is String
          ? int.tryParse(json['type']) ?? 0
          : json['type'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'id': categoryId,
      'icon': icon,
      'type': typeId,
    };
  }
}
