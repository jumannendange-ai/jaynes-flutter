import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'player_screen.dart';

class LiveScreen extends StatefulWidget {
  final SessionService session;
  const LiveScreen({super.key, required this.session});
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  List<Channel> _channels = [];
  List<MatchScore> _scores = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([ApiService.fetchLiveChannels(), ApiService.fetchScores()]);
    setState(() {
      _channels = results[0] as List<Channel>;
      _scores   = results[1] as List<MatchScore>;
      _loading  = false;
    });
  }

  void _open(Channel ch) {
    if (!widget.session.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('⭐ Lipia Premium ili kutazama mechi live!'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.sports_soccer, color: AppColors.red, size: 20),
          SizedBox(width: 8),
          Text('MECHI LIVE'),
        ]),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.text2), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.red))
          : RefreshIndicator(
              color: AppColors.red,
              onRefresh: _load,
              child: CustomScrollView(slivers: [
                // Scores section
                if (_scores.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('MATOKEO YA MECHI', style: TextStyle(
                      color: AppColors.text2, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  )),
                  SliverToBoxAdapter(child: _ScoresGrid(scores: _scores)),
                ],

                // Live channels
                const SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('CHANNELS ZA LIVE', style: TextStyle(
                    color: AppColors.text2, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                )),

                _channels.isEmpty
                    ? const SliverFillRemaining(child: Center(
                        child: Text('Hakuna mechi za live sasa hivi', style: TextStyle(color: AppColors.muted))))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(delegate: SliverChildBuilderDelegate(
                          (_, i) => _LiveCard(channel: _channels[i], onTap: () => _open(_channels[i])),
                          childCount: _channels.length,
                        )),
                      ),
              ]),
            ),
    );
  }
}

class _ScoresGrid extends StatelessWidget {
  final List<MatchScore> scores;
  const _ScoresGrid({required this.scores});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
      ),
      itemCount: scores.length,
      itemBuilder: (_, i) {
        final s = scores[i];
        final isLive = s.status.toLowerCase().contains('live') || RegExp(r"^\d+").hasMatch(s.status);
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isLive ? AppColors.red.withOpacity(0.4) : AppColors.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (s.league != null) Text(s.league!, style: const TextStyle(color: AppColors.muted, fontSize: 9),
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(child: Text(s.homeTeam, style: const TextStyle(color: AppColors.text, fontSize: 11,
                fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.red.withOpacity(0.1) : AppColors.card2,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(s.score, style: TextStyle(
                  color: isLive ? AppColors.red : AppColors.text,
                  fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              Expanded(child: Text(s.awayTeam, style: const TextStyle(color: AppColors.text, fontSize: 11,
                fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            if (isLive) Padding(padding: const EdgeInsets.only(top: 4), child: Row(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(s.status, style: const TextStyle(color: AppColors.red, fontSize: 9, fontWeight: FontWeight.w700)),
            ])),
          ]),
        );
      },
    );
  }
}

class _LiveCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  const _LiveCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: channel.imageUrl != null
              ? CachedNetworkImage(imageUrl: channel.imageUrl!, width: 48, height: 48, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.card2,
                    child: const Icon(Icons.sports_soccer, color: AppColors.muted)))
              : Container(width: 48, height: 48, color: AppColors.card2,
                  child: const Icon(Icons.sports_soccer, color: AppColors.muted)),
        ),
        title: Text(channel.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(channel.category ?? 'LIVE', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        trailing: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(6)),
            child: const Text('TAZAMA', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
