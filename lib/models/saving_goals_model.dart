class SavingGoals {
  final String userId;
  final String name;
  final int statusId;
  final int stored;
  final int target;

  SavingGoals({
    required this.userId,
    required this.name,
    required this.statusId,
    required this.stored,
    required this.target,
  });
  factory SavingGoals.fromJson(Map<String, dynamic> json) {
    return SavingGoals(
      userId: json['user_id'].toString(),
      name: json['name'].toString(),
      statusId: json['status_id'] is String
          ? int.tryParse(json['status_id']) ?? 1
          : json['status_id'] as int,
      stored: json['stored'] is String
          ? int.tryParse(json['stored']) ?? 0
          : json['stored'] as int,
      target: json['target'] is String
          ? int.tryParse(json['target']) ?? 0
          : json['target'] as int,
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
}
