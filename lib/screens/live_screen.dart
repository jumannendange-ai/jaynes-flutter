import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/channel_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'player_screen.dart';

class LiveScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const LiveScreen({super.key, required this.user});
  @override State<LiveScreen> createState() => _State();
}

class _State extends State<LiveScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _tabs = ['Azam', 'NBC', 'Ndani'];
  final Map<int, List<Channel>> _cache = {};
  final Map<int, bool> _loading = {0: false, 1: false, 2: false};
  String _search = '';

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this)..addListener(() { if (!_tab.indexIsChanging) _load(_tab.index); }); _load(0); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load(int i) async {
    if (_cache[i] != null) return;
    setState(() => _loading[i] = true);
    final data = i == 0 ? await ChannelService.fetchAzam() : i == 1 ? await ChannelService.fetchNbc() : await ChannelService.fetchLocal();
    if (mounted) setState(() { _cache[i] = data; _loading[i] = false; });
  }

  bool get _isPremium => AuthService.isPremium(widget.user);

  void _open(Channel ch) {
    if (!_isPremium) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unahitaji subscription.'), backgroundColor: C.red)); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(title: const Text('LIVE CHANNELS'),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(90), child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(onChanged: (v) => setState(() => _search = v.toLowerCase()),
            style: const TextStyle(color: C.text, fontSize: 13),
            decoration: const InputDecoration(hintText: 'Tafuta channel...', prefixIcon: Icon(Icons.search, color: C.muted, size: 20), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
        TabBar(controller: _tab, isScrollable: true, indicatorColor: C.red, labelColor: C.red, unselectedLabelColor: C.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList()),
      ]))),
    body: TabBarView(controller: _tab, children: List.generate(3, (i) {
      if (_loading[i] == true && _cache[i] == null) return const Center(child: CircularProgressIndicator(color: C.red));
      final chs = (_cache[i] ?? []).where((c) => _search.isEmpty || c.name.toLowerCase().contains(_search)).toList();
      if (chs.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, color: C.muted, size: 50), const SizedBox(height: 12),
        const Text('Hakuna channels', style: TextStyle(color: C.muted)), const SizedBox(height: 12),
        TextButton.icon(onPressed: () { _cache.remove(i); _load(i); }, icon: const Icon(Icons.refresh, color: C.red), label: const Text('Jaribu tena', style: TextStyle(color: C.red)))]));
      return GridView.builder(padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: chs.length,
        itemBuilder: (_, j) => GestureDetector(onTap: () => _open(chs[j]),
          child: Container(decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)), clipBehavior: Clip.hardEdge,
            child: Stack(fit: StackFit.expand, children: [
              if (chs[j].image != null) CachedNetworkImage(imageUrl: chs[j].image!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: C.card2)) else Container(color: C.card2),
              Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xEE000000)]))),
              Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Text('● LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
              Center(child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle, border: Border.all(color: Colors.white38)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 24))),
              Positioned(bottom: 8, left: 8, right: 8, child: Text(chs[j].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
            ]))));
    })));
}
