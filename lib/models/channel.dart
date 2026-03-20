import '../utils/constants.dart';

class Channel {
  final String id;
  final String name;
  final String? imageUrl;
  final String streamUrl;
  final String? drmKey;   // "kid:key" format
  final String drmType;   // "CLEARKEY" / "WIDEVINE" / "NONE"
  final String streamType; // "hls" / "dash"
  final String? category;

  Channel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.streamUrl,
    this.drmKey,
    this.drmType = 'NONE',
    this.streamType = 'hls',
    this.category,
  });

  bool get isFree {
    final n = name.toLowerCase();
    return Constants.freeChannels.any((f) => n.contains(f));
  }

  bool get isHls  => streamType == 'hls' || streamUrl.contains('.m3u8');
  bool get isDash => streamType == 'dash' || streamUrl.contains('.mpd');
  bool get hasDrm => drmKey != null && drmKey!.isNotEmpty;

  // Parse from pixtvmax API (key.php)
  factory Channel.fromPixtvmax(Map<String, dynamic> json) {
    String? key;
    final drmType = json['drm_type'] ?? 'NONE';
    if (drmType == 'CLEARKEY') {
      final headers = json['headers'] as Map<String, dynamic>?;
      if (headers != null) {
        final kid = headers['kid'] ?? '';
        final k   = headers['key'] ?? '';
        if (kid.isNotEmpty && k.isNotEmpty) key = '$kid:$k';
      }
    }
    final url = json['mpd_url'] ?? json['url'] ?? '';
    return Channel(
      id:         json['id']?.toString() ?? '',
      name:       json['name'] ?? 'Channel',
      imageUrl:   json['logo_url'] ?? json['image'],
      streamUrl:  url,
      drmKey:     key,
      drmType:    drmType,
      streamType: url.contains('.m3u8') ? 'hls' : 'dash',
      category:   json['category'],
    );
  }

  // Parse from channels.php / live API
  factory Channel.fromLive(Map<String, dynamic> json) {
    final url = json['url'] ?? '';
    return Channel(
      id:         json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name:       json['title'] ?? json['name'] ?? 'Channel',
      imageUrl:   json['logo'] ?? json['image'],
      streamUrl:  url,
      drmType:    'NONE',
      streamType: url.contains('.m3u8') ? 'hls' : 'dash',
      category:   json['category'],
    );
  }

  // Parse from azam.php (zimo + lipopo)
  factory Channel.fromAzam(Map<String, dynamic> json) {
    return Channel(
      id:         json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name:       json['name'] ?? 'Channel',
      imageUrl:   json['image'],
      streamUrl:  json['url'] ?? '',
      drmKey:     json['key'],
      drmType:    json['key'] != null ? 'CLEARKEY' : 'NONE',
      streamType: json['type'] ?? 'hls',
      category:   json['category'],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final String duration;
  final int days;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.days,
  });

  static const List<SubscriptionPlan> all = [
    SubscriptionPlan(id: 'weekly',  name: 'Wiki Moja',    price: 1000,  duration: 'Wiki 1',   days: 7),
    SubscriptionPlan(id: 'monthly', name: 'Mwezi Moja',   price: 3000,  duration: 'Mwezi 1',  days: 30),
    SubscriptionPlan(id: '3month',  name: 'Miezi Mitatu', price: 8000,  duration: 'Miezi 3',  days: 90),
    SubscriptionPlan(id: '6month',  name: 'Miezi Sita',   price: 15000, duration: 'Miezi 6',  days: 180),
    SubscriptionPlan(id: 'annual',  name: 'Mwaka Mzima',  price: 25000, duration: 'Mwaka 1',  days: 365),
  ];
}
