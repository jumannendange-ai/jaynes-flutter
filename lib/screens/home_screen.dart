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
  List<Channel> _all      = [];
  List<Channel> _filtered = [];
  List<MatchScore> _scores = [];
  bool _loading  = true;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.fetchPixtvmaxChannels(),
      ApiService.fetchAzamChannels(),
      ApiService.fetchLocalChannels(),
      ApiService.fetchScores(),
    ]);
    final channels = [...results[0] as List<Channel>, ...results[1] as List<Channel>, ...results[2] as List<Channel>];
    setState(() {
      _all      = channels;
      _filtered = channels;
      _scores   = results[3] as List<MatchScore>;
      _loading  = false;
    });
  }

  void _onSearch(String q) {
    setState(() {
      _search   = q;
      _filtered = _all.where((c) =>
        c.name.toLowerCase().contains(q.toLowerCase()) ||
        (c.category?.toLowerCase().contains(q.toLowerCase()) ?? false)
      ).toList();
    });
  }

  void _openChannel(Channel ch) {
    if (!ch.isFree && !widget.session.isPremium) {
      _showPaywall(ch);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
  }

  void _showPaywall(Channel ch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Icon(Icons.lock, color: AppColors.red, size: 40),
          const SizedBox(height: 12),
          const Text('Lipia ili kutazama', style: TextStyle(
            color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('${ch.name} inahitaji akaunti ya Premium',
            style: const TextStyle(color: AppColors.text2, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...SubscriptionPlan.all.take(2).map((p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.id == 'monthly' ? AppColors.red : AppColors.border),
            ),
            child: ListTile(
              title: Text(p.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
              subtitle: Text(p.duration, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
              trailing: Text('TZS ${p.price}', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
            ),
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.red,
        backgroundColor: AppColors.card,
        onRefresh: _load,
        child: CustomScrollView(slivers: [
          // ─── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('JAYNES MAX TV', style: TextStyle(
                color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1,
              )),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.text2),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tafuta channel...',
                    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: AppColors.muted, size: 18),
                            onPressed: () { _searchCtrl.clear(); _onSearch(''); },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.card2,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            SliverFillRemaining(child: _buildShimmer())
          else ...[
            // ─── Scores bar ────────────────────────────────────────────────
            if (_scores.isNotEmpty)
              SliverToBoxAdapter(child: _ScoresBar(scores: _scores)),

            // ─── Featured channels (horizontal) ───────────────────────────
            if (_search.isEmpty && _all.isNotEmpty)
              SliverToBoxAdapter(child: _FeaturedSection(
                channels: _all.take(6).toList(),
                onTap: _openChannel,
              )),

            // ─── All channels ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(children: [
                  Container(width: 3, height: 16, color: AppColors.red,
                    margin: const EdgeInsets.only(right: 8)),
                  Text(_search.isNotEmpty ? 'Matokeo (${_filtered.length})' : 'CHANNELS ZOTE',
                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800,
                      fontSize: 13, letterSpacing: 1)),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: _filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text('Hakuna channel "$_search"',
                          style: const TextStyle(color: AppColors.muted)),
                      )))
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ChannelCard(channel: _filtered[i], onTap: () => _openChannel(_filtered[i])),
                        childCount: _filtered.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                    ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.card2,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85,
        ),
        itemCount: 12,
        itemBuilder: (_, __) => Container(decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}

// ─── Scores horizontal bar ─────────────────────────────────────────────────
class _ScoresBar extends StatelessWidget {
  final List<MatchScore> scores;
  const _ScoresBar({required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: AppColors.card,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: scores.length,
        itemBuilder: (_, i) {
          final s = scores[i];
          final isLive = s.status.toLowerCase().contains('live') ||
              s.status.toLowerCase().contains('ht') ||
              RegExp(r"^\d+").hasMatch(s.status);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLive ? AppColors.red.withOpacity(0.4) : AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isLive) ...[
                Container(width: 6, height: 6, decoration: const BoxDecoration(
                  color: AppColors.red, shape: BoxShape.circle)),
                const SizedBox(width: 4),
              ],
              Text(s.homeTeam, style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w700)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(s.score, style: TextStyle(
                  color: isLive ? AppColors.red : AppColors.text2,
                  fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              Text(s.awayTeam, style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          );
        },
      ),
    );
  }
}

// ─── Featured section ──────────────────────────────────────────────────────
class _FeaturedSection extends StatelessWidget {
  final List<Channel> channels;
  final Function(Channel) onTap;
  const _FeaturedSection({required this.channels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(children: [
          Container(width: 3, height: 16, color: AppColors.red, margin: const EdgeInsets.only(right: 8)),
          const Text('FEATURED', style: TextStyle(color: AppColors.text,
            fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)),
        ]),
      ),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: channels.length,
          itemBuilder: (_, i) {
            final ch = channels[i];
            return GestureDetector(
              onTap: () => onTap(ch),
              child: Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ch.imageUrl != null
                        ? CachedNetworkImage(imageUrl: ch.imageUrl!, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const _ChannelPlaceholder())
                        : const _ChannelPlaceholder(),
                  ),
                  // Gradient
                  Container(decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                    ),
                  )),
                  // Live badge
                  Positioned(top: 8, left: 8, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.circle, color: Colors.white, size: 6),
                      SizedBox(width: 3),
                      Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ]),
                  )),
                  // Name
                  Positioned(bottom: 10, left: 10, right: 10,
                    child: Text(ch.name, style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── Channel card ──────────────────────────────────────────────────────────
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: channel.imageUrl != null
                  ? CachedNetworkImage(imageUrl: channel.imageUrl!, fit: BoxFit.cover, width: double.infinity,
                      errorWidget: (_, __, ___) => const _ChannelPlaceholder())
                  : const _ChannelPlaceholder(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Text(channel.name,
              style: const TextStyle(color: AppColors.text, fontSize: 10, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ),
        ]),
      ),
    );
  }
}

class _ChannelPlaceholder extends StatelessWidget {
  const _ChannelPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.card2,
    child: const Center(child: Icon(Icons.tv, color: AppColors.muted, size: 28)),
  );
}
