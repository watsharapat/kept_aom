import 'package:kept_aom/features/quick_title/domain/entities/quick_title_entity.dart';

class QuickTitleModel extends QuickTitleEntity {
  QuickTitleModel({
    super.id,
    required super.icon,
    super.userId,
    required super.typeId,
    required super.title,
    super.categoryId,
    super.displayOrder,
  });

  factory QuickTitleModel.fromJson(Map<String, dynamic> json) {
    return QuickTitleModel(
      id: json['id'] as int?,
      icon: json['icon'] as String? ?? '',
      userId: json['user_id'] as String?,
      typeId: json['type_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as int?,
      displayOrder: json['display_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'icon': icon,
      'user_id': userId,
      'type_id': typeId,
      'title': title,
      'category_id': categoryId,
      'display_order': displayOrder,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory QuickTitleModel.fromEntity(QuickTitleEntity entity) {
    return QuickTitleModel(
      id: entity.id,
      icon: entity.icon,
      userId: entity.userId,
      typeId: entity.typeId,
      title: entity.title,
      categoryId: entity.categoryId,
      displayOrder: entity.displayOrder,
    );
  }
}
