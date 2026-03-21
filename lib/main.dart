import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0E0E16),
  ));
  await Supabase.initialize(
    url: 'https://dablnrggyfcddmdeiqxi.supabase.co',
    anonKey: 'sb_publishable_d8mzJ3iulCU7YdlV_lrdQw_32pOzDXc',
  );
  MediaKit.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JAYNES MAX TV',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    home: const SplashScreen(),
  );
}
