import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'supabase_session';

  static Future<void> saveSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session);
  }

  static Future<String?> retrieveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
