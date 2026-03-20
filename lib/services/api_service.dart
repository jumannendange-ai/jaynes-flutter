import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../utils/constants.dart';

class ApiService {
  static final _headers = {
    'Content-Type': 'application/json',
    'User-Agent':   Constants.userAgent,
    'Referer':      Constants.fawaRefer,
    'Origin':       Constants.fawaOrigin,
  };

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${Constants.apiAuth}?action=login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final res = await http.post(
      Uri.parse('${Constants.apiAuth}?action=register'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return jsonDecode(res.body);
  }

  // ─── Channels ──────────────────────────────────────────────────────────────

  // pixtvmax channels (MPD + ClearKey) - from key.php
  static Future<List<Channel>> fetchPixtvmaxChannels() async {
    try {
      final res = await http.get(Uri.parse(Constants.apiPixtvmax), headers: _headers)
          .timeout(const Duration(seconds: 15));
      final List data = jsonDecode(res.body);
      return data
          .where((c) => c['mpd_url'] != null && (c['mpd_url'] as String).contains('.mpd'))
          .map((c) => Channel.fromPixtvmax(c))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Azam channels via zimotv + lipopotv - from azam.php
  static Future<List<Channel>> fetchAzamChannels() async {
    try {
      final res = await http.get(Uri.parse(Constants.apiAzam), headers: _headers)
          .timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['channels'] != null) {
        return (data['channels'] as List).map((c) => Channel.fromAzam(c)).toList();
      }
    } catch (e) {}
    return [];
  }

  // Live match channels - from channels.php
  static Future<List<Channel>> fetchLiveChannels({String category = 'mechi za leo'}) async {
    try {
      final uri = Uri.parse(Constants.apiChannels).replace(
          queryParameters: {'category': category});
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['channels'] != null) {
        return (data['channels'] as List).map((c) => Channel.fromLive(c)).toList();
      }
    } catch (e) {}
    return [];
  }

  // Local channels - local.php
  static Future<List<Channel>> fetchLocalChannels() async {
    try {
      final res = await http.get(Uri.parse(Constants.apiLocal), headers: _headers)
          .timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['channels'] != null) {
        return (data['channels'] as List).map((c) => Channel.fromAzam(c)).toList();
      }
    } catch (e) {}
    return [];
  }

  // Categories
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse(Constants.apiCategories), headers: _headers)
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['categories'] != null) {
        return List<Map<String, dynamic>>.from(data['categories']);
      }
    } catch (e) {}
    return [];
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> submitPayment({
    required String token,
    required String planId,
    required String phone,
    required String method,
  }) async {
    final res = await http.post(
      Uri.parse(Constants.apiPaySubmit),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode({'plan': planId, 'phone': phone, 'method': method}),
    );
    return jsonDecode(res.body);
  }

  // ─── Account status ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAccountStatus(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${Constants.apiAccount}?action=status'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }
}
