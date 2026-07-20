import 'package:google_sign_in/google_sign_in.dart';
import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/auth/data/models/user_model.dart';
import 'package:kept_aom/features/auth/domain/entities/user_entity.dart';
import 'package:kept_aom/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  static const String _webClientId =
      '548737429195-f7pk5bvg9r8m5001hsi3l9jgqf3d6p4c.apps.googleusercontent.com';

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<bool> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email'],
    );
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return false;
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw 'ไม่พบ Access Token หรือ ID Token';
    }

    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response.session != null;
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
}
