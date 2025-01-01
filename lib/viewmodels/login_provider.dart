// lib/features/auth/providers/login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.read(supabaseClientProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  LoginNotifier(this._supabaseClient) : super(const AsyncValue.data(null));

  final SupabaseClient _supabaseClient;
  static const String _webClientId =
      '548737429195-f7pk5bvg9r8m5001hsi3l9jgqf3d6p4c.apps.googleusercontent.com';
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      // กำหนดค่า GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
        scopes: ['email'],
      );

      // บังคับให้ผู้ใช้ Sign Out เพื่อรีเซ็ตสถานะ
      await googleSignIn.signOut();

      // เรียก Sign In ใหม่
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null); // ผู้ใช้ยกเลิกการเลือกบัญชี
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'ไม่พบ Access Token หรือ ID Token';
      }

      // ใช้ idToken และ accessToken สำหรับเซสชันใหม่
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session != null) {
        state = const AsyncValue.data(null); // การลงชื่อเข้าใช้สำเร็จ
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
