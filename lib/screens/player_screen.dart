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
  bool _loading = true;
  String? _error;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPlayer();
  }

  void _initPlayer() {
    _player = Player();
    _controller = VideoController(_player);

    _player.stream.buffering.listen((b) {
      if (mounted) setState(() => _loading = b);
    });
    _player.stream.error.listen((e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    });
    _player.stream.playing.listen((_) {
      if (mounted) setState(() { _loading = false; _error = null; });
    });

    _playStream();
  }

  Future<void> _playStream() async {
    setState(() { _loading = true; _error = null; });

    final ch = widget.channel;
    final url = ch.streamUrl;

    // Build httpHeaders with fawanews spoofing
    final headers = <String, String>{
      'User-Agent':      Constants.userAgent,
      'Referer':         Constants.fawaRefer,
      'Origin':          Constants.fawaOrigin,
      'X-Forwarded-For': Constants.fawaIp,
      'X-Real-IP':       Constants.fawaIp,
    };

    try {
      // Build Media with DRM if needed
      Media media;

      if (ch.hasDrm && ch.drmType == 'CLEARKEY' && ch.drmKey != null) {
        // Parse "kid:key" format
        final parts = ch.drmKey!.split(':');
        if (parts.length == 2) {
          final kid = parts[0].trim();
          final key = parts[1].trim();

          // Build ClearKey JSON for ExoPlayer
          final clearKeyJson = jsonEncode({
            'keys': [{'kty': 'oct', 'k': _hexToBase64Url(key), 'kid': _hexToBase64Url(kid)}],
            'type': 'temporary',
          });

          media = Media(url, httpHeaders: headers, extras: {
            'clearkey': clearKeyJson,
          });
        } else {
          media = Media(url, httpHeaders: headers);
        }
      } else {
        media = Media(url, httpHeaders: headers);
      }

      await _player.open(media);
    } catch (e) {
      setState(() { _error = 'Imeshindwa kupakua: $e'; _loading = false; });
    }
  }

  // Convert hex string to base64url (for ClearKey)
  String _hexToBase64Url(String hex) {
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    final b64 = base64Encode(bytes);
    return b64.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── Video ───────────────────────────────────────────────────────
            Video(
              controller: _controller,
              controls: NoVideoControls,
            ),

            // ─── Loading ─────────────────────────────────────────────────────
            if (_loading)
              const Center(child: CircularProgressIndicator(color: AppColors.accent)),

            // ─── Error ───────────────────────────────────────────────────────
            if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.accent2, size: 48),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.text, fontSize: 13),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _playStream,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Jaribu Tena'),
                    ),
                  ],
                ),
              ),

            // ─── Controls overlay ─────────────────────────────────────────────
            if (_controlsVisible) ...[
              // Top bar
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 36, 12, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.channel.name,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // LIVE badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent2.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Play/Pause
                      StreamBuilder<bool>(
                        stream: _player.stream.playing,
                        builder: (_, snap) {
                          final playing = snap.data ?? false;
                          return _CtrlBtn(
                            icon: playing ? Icons.pause : Icons.play_arrow,
                            onTap: _player.playOrPause,
                          );
                        },
                      ),
                      // Refresh
                      _CtrlBtn(icon: Icons.refresh, onTap: _playStream),
                      // Volume mute
                      StreamBuilder<double>(
                        stream: _player.stream.volume,
                        builder: (_, snap) {
                          final vol = snap.data ?? 100;
                          return _CtrlBtn(
                            icon: vol == 0 ? Icons.volume_off : Icons.volume_up,
                            onTap: () => _player.setVolume(vol == 0 ? 100 : 0),
                          );
                        },
                      ),
                      // Fullscreen toggle
                      _CtrlBtn(
                        icon: Icons.fullscreen,
                        onTap: () {
                          final o = MediaQuery.of(context).orientation;
                          SystemChrome.setPreferredOrientations(
                            o == Orientation.landscape
                                ? [DeviceOrientation.portraitUp]
                                : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
