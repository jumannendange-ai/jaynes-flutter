import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SessionService {
  static SessionService? _instance;
  late SharedPreferences _prefs;

  SessionService._();
  static Future<SessionService> getInstance() async {
    if (_instance == null) {
      _instance = SessionService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<void> saveToken(String token) => _prefs.setString(Constants.prefToken, token);
  String? get token => _prefs.getString(Constants.prefToken);
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> saveUser(String id, String email, String name) async {
    await _prefs.setString(Constants.prefUserId, id);
    await _prefs.setString(Constants.prefUserEmail, email);
    await _prefs.setString(Constants.prefUserName, name);
  }

  String get userId    => _prefs.getString(Constants.prefUserId)    ?? '';
  String get userEmail => _prefs.getString(Constants.prefUserEmail) ?? '';
  String get userName  => _prefs.getString(Constants.prefUserName)  ?? 'Mtumiaji';

  Future<void> setPremium(bool premium, String expires) async {
    await _prefs.setBool(Constants.prefIsPremium, premium);
    await _prefs.setString(Constants.prefSubExpires, expires);
  }

  bool   get isPremium  => _prefs.getBool(Constants.prefIsPremium)    ?? false;
  String get subExpires => _prefs.getString(Constants.prefSubExpires) ?? '';

  Future<void> logout() => _prefs.clear();
}
