import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kept_aom/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  final supabase = Supabase.instance.client;

  Future<void> _googleSignIn() async {
    // Web Client ID ที่คุณลงทะเบียนไว้กับ Google Cloud
    const webClientId =
        '548737429195-f7pk5bvg9r8m5001hsi3l9jgqf3d6p4c.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // หากผู้ใช้ยกเลิกการเข้าสู่ระบบ
      return;
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw 'ไม่พบ Access Token หรือ ID Token';
    }

    try {
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      if (response.session != null) {
        // await _saveUserData(googleUser);
        // หากเข้าสู่ระบบสำเร็จ ให้นำทางไปที่หน้า ProfilePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } catch (error) {
      // หากเกิดข้อผิดพลาดให้จัดการข้อผิดพลาดที่นี่
      print('Error logging in with Google: $error');
    }
  }

  // Future<void> _saveUserData(GoogleSignInAccount googleUser) async {
  //   // ข้อมูลผู้ใช้จาก Google
  //   final email = googleUser.email;
  //   final name = googleUser.displayName;

  //   try {
  //     // เพิ่มหรืออัปเดตข้อมูลผู้ใช้ใน Table `users`
  //     final userId = supabase.auth.currentUser?.id;
  //     await supabase.from('users').upsert({
  //       // 'id': userId, // ใช้ user_id จาก Supabase เป็น Primary Key
  //       'email': email,
  //       'name': name,
  //     });
  //   } catch (error) {
  //     print('Error saving user data: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _googleSignIn,
          child: const Text('Google login'),
        ),
      ),
    );
  }
}
