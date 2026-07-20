import 'package:kept_aom/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> signInWithGoogle();
  Future<void> signOut();
  UserEntity? getCurrentUser();
}
