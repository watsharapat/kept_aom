class UserEntity {
  final String email;
  final String name;
  final String? avatarUrl;

  UserEntity({
    required this.email,
    required this.name,
    this.avatarUrl,
  });
}
