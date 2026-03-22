import 'dart:convert';
import 'package:http/http.dart' as http;

class Channel {
  final String name;
  final String url;
  final String? image;
  final String? key;
  final String category;
  final bool isDash;

  const Channel({required this.name, required this.url, this.image, this.key, this.category = 'Live', this.isDash = false});

  factory Channel.fromJson(Map m) => Channel(
    name: m['name'] ?? '', url: m['url'] ?? m['mpd_url'] ?? '',
    image: m['image'] ?? m['logo'], key: m['key'],
    category: m['category'] ?? 'Live',
    isDash: (m['url'] ?? m['mpd_url'] ?? '').toString().contains('.mpd'));
}

class ChannelService {
  static const _base = 'https://dde.ct.ws';
  static const _h = {'User-Agent': 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36', 'Referer': 'http://www.fawanews.sc/', 'Origin': 'http://www.fawanews.sc'};

  static Future<List<Channel>> fetchAzam() => _f('$_base/azam.php');
  static Future<List<Channel>> fetchNbc()   => _f('$_base/nbc.php');
  static Future<List<Channel>> fetchLocal() => _f('$_base/local.php');

  static Future<List<Channel>> _f(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: _h).timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['channels'] != null) {
        return (data['channels'] as List).map((c) => Channel.fromJson(c as Map)).toList();
      }
    } catch (_) {}
    return [];
  }
}
