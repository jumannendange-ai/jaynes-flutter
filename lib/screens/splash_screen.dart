import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  final SessionService session;
  const SplashScreen({super.key, required this.session});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.session.isLoggedIn
              ? MainScreen(session: widget.session)
              : AuthScreen(session: widget.session),
        ),
      );
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 30)],
                ),
                child: const Icon(Icons.play_circle_filled, color: AppColors.accent, size: 60),
              ),
              const SizedBox(height: 24),
              const Text('JAYNES', style: TextStyle(
                color: AppColors.accent, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 6,
              )),
              const Text('MAX TV', style: TextStyle(
                color: AppColors.text, fontSize: 22, letterSpacing: 8,
              )),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32, height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
