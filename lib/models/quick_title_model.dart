class QuickTitle {
  final int id;
  final String icon;
  final String userId;
  final String title;
  final int typeId;

  QuickTitle({
    required this.id,
    required this.icon,
    required this.userId,
    required this.typeId,
    required this.title,
  });
  factory QuickTitle.fromJson(Map<String, dynamic> json) {
    return QuickTitle(
      id: int.parse(json['id']),
      icon: json['icon'].toString(),
      userId: json['user_id'].toString(),
      typeId: int.parse(json['type_id']),
      title: json['title'].toString(),
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
}
