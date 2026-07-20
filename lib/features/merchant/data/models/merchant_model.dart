import 'package:kept_aom/features/merchant/domain/entities/merchant_entity.dart';

class MerchantModel extends MerchantEntity {
  MerchantModel({
    super.id,
    required super.name,
    super.normalizedName,
    required super.titleName,
    required super.titleIcon,
    super.categoryId,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      normalizedName: json['normalized_name'] as String?,
      titleName: json['title_name'] as String? ?? '',
      titleIcon: json['title_icon'] as String? ?? '',
      categoryId: json['category_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalized_name': normalizedName,
      'title_name': titleName,
      'titleIcon': titleIcon,
      'category_id': categoryId,
    };
  }

  factory MerchantModel.fromEntity(MerchantEntity entity) {
    return MerchantModel(
      id: entity.id,
      name: entity.name,
      normalizedName: entity.normalizedName,
      titleName: entity.titleName,
      titleIcon: entity.titleIcon,
      categoryId: entity.categoryId,
    );
  }
}
