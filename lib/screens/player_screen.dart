import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/channel_service.dart';

class PlayerScreen extends StatelessWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(channel.name, style: const TextStyle(color: Colors.white)),
    ),
    body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.play_circle_fill, color: C.red, size: 80),
      SizedBox(height: 16),
      Text('Player inakuja...', style: TextStyle(color: Colors.white70)),
    ])),
  );
}
