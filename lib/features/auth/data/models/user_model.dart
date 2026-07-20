import 'package:kept_aom/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    required super.name,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
      };
}
