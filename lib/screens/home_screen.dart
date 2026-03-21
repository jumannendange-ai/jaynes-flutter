import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['name'] ?? '';
    final plan = user['plan'] ?? 'free';
    final isPrem = AuthService.isPremium(user);
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.play_circle_fill, color: C.red, size: 26),
          const SizedBox(width: 8),
          const Text('JAYNES MAX TV', style: TextStyle(color: C.red, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const Spacer(),
          if (!isPrem) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: C.red.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: C.red.withOpacity(0.4))),
            child: const Text('TRIAL', style: TextStyle(color: C.red, fontSize: 10, fontWeight: FontWeight.w800))),
        ]),
      ),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 90, height: 90,
            decoration: BoxDecoration(color: C.card, shape: BoxShape.circle,
              border: Border.all(color: C.red.withOpacity(0.5), width: 2)),
            child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'J',
              style: const TextStyle(color: C.red, fontSize: 36, fontWeight: FontWeight.w900)))),
          const SizedBox(height: 16),
          Text('Karibu $name!', style: const TextStyle(color: C.text, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isPrem ? C.green.withOpacity(0.1) : C.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isPrem ? C.green.withOpacity(0.4) : C.red.withOpacity(0.4))),
            child: Text(isPrem ? 'Premium ✓' : 'Plan: $plan',
              style: TextStyle(color: isPrem ? C.green : C.red, fontSize: 13, fontWeight: FontWeight.w700))),
          const SizedBox(height: 32),
          const Text('Nenda Live kuona channels', style: TextStyle(color: C.text2, fontSize: 14)),
        ]),
      )),
    );
  }
}
