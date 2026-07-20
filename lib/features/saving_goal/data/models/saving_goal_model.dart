import 'package:kept_aom/features/saving_goal/domain/entities/saving_goal_entity.dart';

class SavingGoalModel extends SavingGoalEntity {
  SavingGoalModel({
    required super.userId,
    required super.name,
    required super.statusId,
    required super.stored,
    required super.target,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      statusId: json['status_id'] is String
          ? int.tryParse(json['status_id']) ?? 1
          : json['status_id'] as int? ?? 1,
      stored: json['stored'] is String
          ? int.tryParse(json['stored']) ?? 0
          : json['stored'] as int? ?? 0,
      target: json['target'] is String
          ? int.tryParse(json['target']) ?? 0
          : json['target'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'status_id': statusId,
      'stored': stored,
      'target': target,
    };
  }

  factory SavingGoalModel.fromEntity(SavingGoalEntity entity) {
    return SavingGoalModel(
      userId: entity.userId,
      name: entity.name,
      statusId: entity.statusId,
      stored: entity.stored,
      target: entity.target,
    );
  }
}
