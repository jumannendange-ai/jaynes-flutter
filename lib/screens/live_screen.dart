import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LiveScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const LiveScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(title: const Text('LIVE CHANNELS')),
    body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.live_tv, color: C.red, size: 60),
      SizedBox(height: 16),
      Text('Channels zinaongezwa...', style: TextStyle(color: C.text2, fontSize: 15)),
    ])),
  );
}
