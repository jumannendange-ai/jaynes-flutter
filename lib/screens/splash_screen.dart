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
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget.session.isLoggedIn
          ? MainScreen(session: widget.session)
          : AuthScreen(session: widget.session),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ─── Background glow ───────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8 * _pulse.value,
                    colors: [
                      AppColors.red.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Content ───────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.red.withOpacity(0.6), width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 40, spreadRadius: 4),
                            BoxShadow(color: AppColors.red.withOpacity(0.1), blurRadius: 80, spreadRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.play_circle_filled, color: AppColors.red, size: 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Text
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.red, Color(0xFFFF6B6B)],
                          ).createShader(bounds),
                          child: const Text('JAYNES', style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          )),
                        ),
                        const Text('MAX TV', style: TextStyle(
                          color: AppColors.text2,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 12,
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Loading dots
                FadeTransition(
                  opacity: _textFade,
                  child: const _LoadingDots(),
                ),
              ],
            ),
          ),

          // ─── Version ───────────────────────────────────────────────────────
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: const Text('v6.0.0', textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
        ..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.forward();
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _ctrls[i],
        builder: (_, __) => Container(
          width: 6, height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.4 + 0.6 * _ctrls[i].value),
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }
}
