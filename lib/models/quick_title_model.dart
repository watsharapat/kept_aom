class QuickTitle {
  final String userId;
  final String title;
  final int typeId;

  QuickTitle({
    required this.userId,
    required this.typeId,
    required this.title,
  });
  factory QuickTitle.fromJson(Map<String, dynamic> json) {
    return QuickTitle(
      userId: json['user_id'].toString(),
      typeId: json['type_id'] is String
          ? int.tryParse(json['type_id']) ?? 1
          : json['type_id'] as int,
      title: json['title'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type_id': typeId,
      'title': title,
    };
  }
}
