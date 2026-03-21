import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LiveScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const LiveScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('LIVE CHANNELS')),
      body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.live_tv, color: AppColors.red, size: 60),
        SizedBox(height: 16),
        Text('Channels zinapakia...', style: TextStyle(color: AppColors.text2)),
      ])),
    );
  }
}
