import 'package:kept_aom/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.userId,
    required super.name,
    required super.categoryId,
    required super.icon,
    required super.typeId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] as int? ?? 0,
      icon: json['icon']?.toString() ?? '',
      typeId: json['type'] is String
          ? int.tryParse(json['type']) ?? 0
          : json['type'] as int? ?? 0,
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

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      userId: entity.userId,
      name: entity.name,
      categoryId: entity.categoryId,
      icon: entity.icon,
      typeId: entity.typeId,
    );
  }
}
