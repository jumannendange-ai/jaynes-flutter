import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _State();
}

class _State extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final session = await AuthService.getSession();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => session != null ? MainScreen(user: session) : const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 100, height: 100,
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.red.withOpacity(0.6), width: 2),
          boxShadow: [BoxShadow(color: C.red.withOpacity(0.3), blurRadius: 40)]),
        child: const Icon(Icons.play_circle_fill, color: C.red, size: 60)),
      const SizedBox(height: 20),
      const Text('JAYNES MAX TV', style: TextStyle(color: C.red, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
      const SizedBox(height: 6),
      const Text('Tanzania Premium Streaming', style: TextStyle(color: C.text2, fontSize: 13)),
      const SizedBox(height: 40),
      const CircularProgressIndicator(color: C.red, strokeWidth: 2.5),
    ])),
  );
}
