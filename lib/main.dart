import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'services/session_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF050508),
  ));
  final session = await SessionService.getInstance();
  runApp(JaynesApp(session: session));
}

class JaynesApp extends StatelessWidget {
  final SessionService session;
  const JaynesApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JAYNES MAX TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SplashScreen(session: session),
    );
  }
}
