class UserModel {
  final String email;
  final String name;

  UserModel({
    required this.email,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
      };
}
