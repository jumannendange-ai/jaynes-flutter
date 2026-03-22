import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/channel_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});
  @override State<HomeScreen> createState() => _State();
}

class _State extends State<HomeScreen> {
  List<Channel> _azam = [], _nbc = [], _local = [];
  bool _loading = true;
  int _page = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await Future.wait([ChannelService.fetchAzam(), ChannelService.fetchNbc(), ChannelService.fetchLocal()]);
    if (mounted) setState(() { _azam = r[0]; _nbc = r[1]; _local = r[2]; _loading = false; });
  }

  bool get _isPremium => AuthService.isPremium(widget.user);

  void _open(Channel ch) {
    if (!_isPremium) { _paywall(); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
  }

  void _paywall() => showModalBottomSheet(context: context, backgroundColor: C.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: C.muted, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 20),
      const Icon(Icons.lock_rounded, color: C.red, size: 48),
      const SizedBox(height: 12),
      const Text('Subscription Inahitajika', style: TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Lipa kidogo ili uone channels zote', textAlign: TextAlign.center, style: TextStyle(color: C.text2, fontSize: 13)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('TAZAMA MIPANGO'))),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sio sasa', style: TextStyle(color: C.muted))),
    ])));

  @override
  Widget build(BuildContext context) {
    final featured = [..._nbc.take(3), ..._azam.take(3)];
    return Scaffold(backgroundColor: C.bg,
      body: RefreshIndicator(color: C.red, onRefresh: _load,
        child: CustomScrollView(slivers: [
          SliverAppBar(floating: true, snap: true, backgroundColor: C.bg,
            title: Row(children: [
              const Icon(Icons.play_circle_fill, color: C.red, size: 26), const SizedBox(width: 8),
              const Text('JAYNES MAX TV', style: TextStyle(color: C.red, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const Spacer(),
              if (!_isPremium) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: C.red.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: C.red.withOpacity(0.4))),
                child: const Text('TRIAL', style: TextStyle(color: C.red, fontSize: 10, fontWeight: FontWeight.w800))),
            ])),
          if (_loading) const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: C.red)))
          else SliverList(delegate: SliverChildListDelegate([
            if (featured.isNotEmpty) ...[
              SizedBox(height: 200, child: PageView.builder(itemCount: featured.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => GestureDetector(onTap: () => _open(featured[i]),
                  child: Container(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: C.red.withOpacity(0.3))),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(fit: StackFit.expand, children: [
                      featured[i].image != null ? CachedNetworkImage(imageUrl: featured[i].image!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: C.card2)) : Container(color: C.card2),
                      Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC000000)]))),
                      Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)), child: const Text('● LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)))),
                      Center(child: Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle, border: Border.all(color: Colors.white38)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 30))),
                      Positioned(bottom: 12, left: 14, child: Text(featured[i].name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
                    ]))))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(featured.length, (i) =>
                Container(width: i == _page ? 20 : 6, height: 4, margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  decoration: BoxDecoration(color: i == _page ? C.red : C.muted, borderRadius: BorderRadius.circular(2))))),
              const SizedBox(height: 8),
            ],
            if (_nbc.isNotEmpty) ...[_hdr('🏆 NBC Premier League', _nbc.length), _hList(_nbc), const SizedBox(height: 16)],
            if (_azam.isNotEmpty) ...[_hdr('📡 Azam Channels', _azam.length), _hList(_azam), const SizedBox(height: 16)],
            if (_local.isNotEmpty) ...[_hdr('📺 Channels za Ndani', _local.length), _hList(_local), const SizedBox(height: 16)],
            const SizedBox(height: 80),
          ])),
        ])));
  }
Widget _hdr(String t, int n) => Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Row(children: [Expanded(child: Text(t, style: const TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w800))), Text('$n', style: const TextStyle(color: C.muted, fontSize: 12))]));

  Widget _hList(List<Channel> chs) => SizedBox(height: 110, child: ListView.builder(
    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
    itemCount: chs.length, itemBuilder: (_, i) => GestureDetector(onTap: () => _open(chs[i]),
      child: Container(width: 140, margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
        clipBehavior: Clip.hardEdge,
        child: Stack(fit: StackFit.expand, children: [
          if (chs[i].image != null) CachedNetworkImage(imageUrl: chs[i].image!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: C.card2)) else Container(color: C.card2),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xDD000000)]))),
          Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)))),
          Positioned(bottom: 6, left: 0, right: 0, child: Text(chs[i].name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
        ])))));
}
