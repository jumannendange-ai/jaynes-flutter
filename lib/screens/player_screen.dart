import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/channel_service.dart';
import '../utils/theme.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});
  @override State<PlayerScreen> createState() => _State();
}

class _State extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(children: [
      const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_outline, color: C.red, size: 80),
        SizedBox(height: 16),
        Text('Player inafungua...', style: TextStyle(color: Colors.white70, fontSize: 15))])),
      Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text(widget.channel.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: const Text('● LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
        ])))),
    ]));
}
