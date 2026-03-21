import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _sb = Supabase.instance.client;

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final res = await _sb.auth.signUp(email: email, password: password, data: {'full_name': name});
      if (res.user == null) return {'success': false, 'error': 'Usajili umeshindwa.'};
      final uid = res.user!.id;
      final trialEnd = DateTime.now().add(const Duration(minutes: 30)).toIso8601String();
      await _sb.from('profiles').upsert({'id': uid, 'email': email, 'full_name': name, 'plan': 'trial', 'trial_end': trialEnd});
      await _save(res.session!.accessToken, uid, email, name, 'trial', trialEnd, '');
      return {'success': true, 'user': {'uid': uid, 'email': email, 'name': name, 'plan': 'trial', 'trial_end': trialEnd, 'sub_end': ''}};
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('already')) msg = 'Email hii tayari imesajiliwa.';
      return {'success': false, 'error': msg};
    } catch (e) {
      return {'success': false, 'error': 'Tatizo la muunganiko. Angalia internet.'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _sb.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) return {'success': false, 'error': 'Email au nywila si sahihi.'};
      final uid = res.user!.id;
      final profile = await _sb.from('profiles').select('full_name,plan,trial_end,sub_end').eq('id', uid).maybeSingle();
      final name = profile?['full_name'] ?? email.split('@')[0];
      final plan = profile?['plan'] ?? 'free';
      final trialEnd = profile?['trial_end'] ?? '';
      final subEnd = profile?['sub_end'] ?? '';
      await _save(res.session!.accessToken, uid, email, name, plan, trialEnd, subEnd);
      return {'success': true, 'user': {'uid': uid, 'email': email, 'name': name, 'plan': plan, 'trial_end': trialEnd, 'sub_end': subEnd}};
    } on AuthException {
      return {'success': false, 'error': 'Email au nywila si sahihi.'};
    } catch (e) {
      return {'success': false, 'error': 'Tatizo la muunganiko. Angalia internet.'};
    }
  }

  static Future<void> logout() async {
    await _sb.auth.signOut();
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final p = await SharedPreferences.getInstance();
    final token = p.getString('token');
    if (token == null) return null;
    return {'token': token, 'uid': p.getString('uid') ?? '', 'email': p.getString('email') ?? '', 'name': p.getString('name') ?? '', 'plan': p.getString('plan') ?? 'free', 'trial_end': p.getString('trial_end') ?? '', 'sub_end': p.getString('sub_end') ?? ''};
  }

  static bool isPremium(Map<String, dynamic> user) {
    final plan = user['plan'] ?? 'free';
    final subEnd = user['sub_end'] ?? '';
    final trialEnd = user['trial_end'] ?? '';
    if (plan == 'premium' && subEnd.isNotEmpty) return DateTime.tryParse(subEnd)?.isAfter(DateTime.now()) ?? false;
    if (plan == 'trial' && trialEnd.isNotEmpty) return DateTime.tryParse(trialEnd)?.isAfter(DateTime.now()) ?? false;
    return false;
  }

  static Future<void> _save(String token, String uid, String email, String name, String plan, String trialEnd, String subEnd) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('token', token);
    await p.setString('uid', uid);
    await p.setString('email', email);
    await p.setString('name', name);
    await p.setString('plan', plan);
    await p.setString('trial_end', trialEnd);
    await p.setString('sub_end', subEnd);
  }
}
