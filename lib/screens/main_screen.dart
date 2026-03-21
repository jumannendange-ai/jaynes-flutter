import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'live_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainScreen({super.key, required this.user});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  late Map<String, dynamic> _user;

  @override
  void initState() { super.initState(); _user = Map.from(widget.user); }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(user: _user),
      LiveScreen(user: _user),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Nyumbani'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv_rounded), label: 'Live'),
        ],
      ),
    );
  }
}
DARTcat > lib/screens/auth_screen.dart << 'DART'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _isLogin = true, _loading = false, _showPass = false;
  String _error = '';

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    final name  = _nameCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) { setState(() => _error = 'Jaza email na nywila'); return; }
    if (!_isLogin && name.isEmpty) { setState(() => _error = 'Jaza jina lako'); return; }
    if (pass.length < 6) { setState(() => _error = 'Nywila lazima iwe herufi 6+'); return; }
    setState(() { _loading = true; _error = ''; });
    final data = _isLogin ? await AuthService.login(email, pass) : await AuthService.register(email, pass, name);
    if (!mounted) return;
    if (data['success'] == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(user: data['user'])));
    } else {
      setState(() => _error = data['error'] ?? 'Imeshindwa. Jaribu tena.');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 50),
        Center(child: Container(width: 88, height: 88,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.red.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.25), blurRadius: 35)]),
          child: const Icon(Icons.play_circle_fill, color: AppColors.red, size: 50))),
        const SizedBox(height: 18),
        const Center(child: Text('JAYNES MAX TV', style: TextStyle(color: AppColors.red, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4))),
        const SizedBox(height: 6),
        Center(child: Text(_isLogin ? 'Ingia kwenye akaunti yako' : 'Tengeneza akaunti mpya', style: const TextStyle(color: AppColors.text2, fontSize: 13))),
        const SizedBox(height: 36),
        Container(decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            _tab('INGIA', _isLogin, () => setState(() { _isLogin = true; _error = ''; })),
            _tab('JIANDIKISHE', !_isLogin, () => setState(() { _isLogin = false; _error = ''; })),
          ])),
        const SizedBox(height: 24),
        if (!_isLogin) ...[_field(_nameCtrl, 'Jina lako kamili', Icons.person_outline), const SizedBox(height: 12)],
        _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        TextField(controller: _passCtrl, obscureText: !_showPass,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(hintText: 'Nywila',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted, size: 20),
            suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppColors.muted, size: 20),
              onPressed: () => setState(() => _showPass = !_showPass)))),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.red.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13))),
            ])),
        ],
        const SizedBox(height: 22),
        SizedBox(height: 52, child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(_isLogin ? 'INGIA' : 'JIANDIKISHE'))),
        const SizedBox(height: 16),
        Center(child: TextButton(onPressed: () => setState(() { _isLogin = !_isLogin; _error = ''; }),
          child: RichText(text: TextSpan(style: const TextStyle(color: AppColors.text2, fontSize: 13), children: [
            TextSpan(text: _isLogin ? 'Huna akaunti? ' : 'Una akaunti? '),
            TextSpan(text: _isLogin ? 'Jiandikishe' : 'Ingia', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
          ])))),
      ]))),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? AppColors.red : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : AppColors.muted, fontSize: 13, fontWeight: FontWeight.w700)))));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType? type}) =>
    TextField(controller: ctrl, keyboardType: type,
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.muted, size: 20)));
}
DARTcat > lib/utils/theme.dart << 'DART'
import 'package:flutter/material.dart';

class AppColors {
  static const bg    = Color(0xFF0A0A0F);
  static const card  = Color(0xFF13131A);
  static const card2 = Color(0xFF1A1A24);
  static const red   = Color(0xFFE50914);
  static const text  = Color(0xFFFFFFFF);
  static const text2 = Color(0xFFB0B0C0);
  static const muted = Color(0xFF606070);
  static const gold  = Color(0xFFFFD700);
  static const green = Color(0xFF00C853);
  static const border= Color(0xFF2A2A35);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  primaryColor: AppColors.red,
  colorScheme: const ColorScheme.dark(primary: AppColors.red, surface: AppColors.card),
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg, elevation: 0,
    titleTextStyle: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1),
    iconTheme: IconThemeData(color: AppColors.text)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0E0E16), selectedItemColor: AppColors.red,
    unselectedItemColor: AppColors.muted, type: BottomNavigationBarType.fixed),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
  elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.red, foregroundColor: Colors.white, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
);
