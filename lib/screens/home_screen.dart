import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/channel.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final SessionService session;
  const HomeScreen({super.key, required this.session});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Channel> _channels = [];
  List<Channel> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.fetchPixtvmaxChannels(),
      ApiService.fetchAzamChannels(),
    ]);
    final all = [...results[0], ...results[1]];
    setState(() {
      _channels = all;
      _filtered = all;
      _loading  = false;
    });
  }

  void _onSearch(String q) {
    setState(() {
      _search   = q;
      _filtered = _channels.where((c) =>
          c.name.toLowerCase().contains(q.toLowerCase()) ||
          (c.category?.toLowerCase().contains(q.toLowerCase()) ?? false)
      ).toList();
    });
  }

  void _openChannel(Channel ch) {
    if (!ch.isFree && !widget.session.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('⭐ Lipia ili kutazama channel hii!'),
        backgroundColor: AppColors.accent2,
      ));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PlayerScreen(channel: ch),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('JAYNES MAX TV'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Tafuta channels...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: _loading
            ? _buildShimmer()
            : _filtered.isEmpty
                ? const Center(child: Text('Hakuna channels', style: TextStyle(color: AppColors.muted)))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _ChannelCard(
                      channel: _filtered[i],
                      onTap: () => _openChannel(_filtered[i]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.card,
        highlightColor: AppColors.card2,
        child: Container(decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        )),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  const _ChannelCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    channel.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: channel.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.tv, color: AppColors.muted, size: 48),
                          )
                        : const Icon(Icons.tv, color: AppColors.muted, size: 48),
                    // Lock overlay
                    if (!channel.isFree)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.lock, color: AppColors.gold, size: 14),
                        ),
                      ),
                    // Live badge
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent2.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 3),
                            Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Name & category
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channel.name,
                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.category != null)
                    Text(channel.category!,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
