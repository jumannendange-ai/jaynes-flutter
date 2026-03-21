import 'package:flutter/material.dart';
import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('JAYNES MAX TV')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.play_circle_fill, color: AppColors.red, size: 80),
        const SizedBox(height: 16),
        Text('Karibu ${user['name'] ?? ''}!', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Plan: ${user['plan'] ?? 'free'}', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
      ])),
    );
  }
}
