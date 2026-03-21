import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = await AuthService.getSession();
    if (!mounted) return;
    if (session != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(user: session)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.red.withOpacity(0.6), width: 2),
            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 40)]),
          child: const Icon(Icons.play_circle_fill, color: AppColors.red, size: 60)),
        const SizedBox(height: 20),
        const Text('JAYNES MAX TV', style: TextStyle(color: AppColors.red, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
        const SizedBox(height: 6),
        const Text('Tanzania Premium Streaming', style: TextStyle(color: AppColors.text2, fontSize: 13)),
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: AppColors.red, strokeWidth: 2.5),
      ])),
    );
  }
}
