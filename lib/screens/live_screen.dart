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
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ch = await ApiService.fetchLiveChannels();
    setState(() { _channels = ch; _loading = false; });
  }

  void _open(Channel ch) {
    if (!widget.session.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('⭐ Lipia ili kutazama mechi live!'),
        backgroundColor: AppColors.accent2,
      ));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: ch)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('⚽ MECHI LIVE')),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _channels.isEmpty
                ? const Center(child: Text('Hakuna mechi za live sasa hivi',
                    style: TextStyle(color: AppColors.muted)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _channels.length,
                    itemBuilder: (_, i) {
                      final ch = _channels[i];
                      return Card(
                        color: AppColors.card,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ch.imageUrl != null
                                ? CachedNetworkImage(imageUrl: ch.imageUrl!,
                                    width: 48, height: 48, fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: AppColors.muted))
                                : const Icon(Icons.sports_soccer, color: AppColors.muted, size: 48),
                          ),
                          title: Text(ch.name,
                              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                          subtitle: Text(ch.category ?? 'LIVE',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                            ),
                            child: const Text('TAZAMA', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          onTap: () => _open(ch),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
