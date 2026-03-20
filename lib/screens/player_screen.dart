import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/channel.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _loading  = true;
  String? _error;
  bool _controls = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _player = Player();
    _controller = VideoController(_player);
    _player.stream.buffering.listen((b) { if (mounted) setState(() => _loading = b); });
    _player.stream.error.listen((e) { if (mounted) setState(() { _error = e; _loading = false; }); });
    _player.stream.playing.listen((_) { if (mounted) setState(() { _loading = false; _error = null; }); });
    _playStream();
  }

  Future<void> _playStream() async {
    setState(() { _loading = true; _error = null; });
    final ch = widget.channel;
    final headers = <String, String>{
      'User-Agent': Constants.userAgent,
      'Referer': Constants.fawaRefer,
      'Origin': Constants.fawaOrigin,
      'X-Forwarded-For': Constants.fawaIp,
      'X-Real-IP': Constants.fawaIp,
    };
    try {
      Media media;
      if (ch.hasDrm && ch.drmType == 'CLEARKEY' && ch.drmKey != null) {
        final parts = ch.drmKey!.split(':');
        if (parts.length == 2) {
          final clearKeyJson = jsonEncode({
            'keys': [{'kty': 'oct', 'k': _hexToBase64Url(parts[1].trim()), 'kid': _hexToBase64Url(parts[0].trim())}],
            'type': 'temporary',
          });
          media = Media(ch.streamUrl, httpHeaders: headers, extras: {'clearkey': clearKeyJson});
        } else {
          media = Media(ch.streamUrl, httpHeaders: headers);
        }
      } else {
        media = Media(ch.streamUrl, httpHeaders: headers);
      }
      await _player.open(media);
    } catch (e) {
      setState(() { _error = 'Imeshindwa: $e'; _loading = false; });
    }
  }

  String _hexToBase64Url(String hex) {
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    return base64Encode(bytes).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    if (_controls) Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _controls = false); });
  }

  @override
  void dispose() {
    _player.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(fit: StackFit.expand, children: [
          Video(controller: _controller, controls: NoVideoControls),

          if (_loading) const Center(child: CircularProgressIndicator(color: AppColors.red)),

          if (_error != null) Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _playStream, icon: const Icon(Icons.refresh), label: const Text('Jaribu Tena')),
          ])),

          if (_controls) ...[
            // Top bar
            Positioned(top: 0, left: 0, right: 0, child: Container(
              padding: const EdgeInsets.fromLTRB(8, 32, 16, 16),
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              )),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 4),
                Expanded(child: Text(widget.channel.name, style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, color: Colors.white, size: 6),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ]),
            )),

            // Bottom controls
            Positioned(bottom: 0, left: 0, right: 0, child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              )),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                StreamBuilder<bool>(
                  stream: _player.stream.playing,
                  builder: (_, snap) => _Btn(
                    icon: (snap.data ?? false) ? Icons.pause : Icons.play_arrow,
                    onTap: _player.playOrPause,
                  ),
                ),
                _Btn(icon: Icons.refresh, onTap: _playStream),
                StreamBuilder<double>(
                  stream: _player.stream.volume,
                  builder: (_, snap) => _Btn(
                    icon: (snap.data ?? 100) == 0 ? Icons.volume_off : Icons.volume_up,
                    onTap: () => _player.setVolume((snap.data ?? 100) == 0 ? 100 : 0),
                  ),
                ),
                _Btn(icon: Icons.fullscreen, onTap: () {
                  final o = MediaQuery.of(context).orientation;
                  SystemChrome.setPreferredOrientations(o == Orientation.landscape
                      ? [DeviceOrientation.portraitUp]
                      : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                }),
              ]),
            )),
          ],
        ]),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    ),
  );
}
