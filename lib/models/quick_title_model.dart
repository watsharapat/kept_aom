class QuickTitle {
  final int? id;
  final String icon;
  final String? userId;
  final String title;
  final int typeId;

  QuickTitle({
    this.id,
    required this.icon,
    this.userId,
    required this.typeId,
    required this.title,
  });
  factory QuickTitle.fromJson(Map<String, dynamic> json) {
    return QuickTitle(
      id: json['id'] as int?,
      icon: json['icon'] as String,
      userId: json['user_id'] as String?,
      typeId: json['type_id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'user_id': userId,
      'type_id': typeId,
      'title': title,
    };
  }

  Map<String, dynamic> toJsonWithoutId() {
    return {
      'icon': icon,
      'user_id': userId,
      'type_id': typeId,
      'title': title,
    };
  }
}
