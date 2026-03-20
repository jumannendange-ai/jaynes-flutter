import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  final SessionService session;
  const AuthScreen({super.key, required this.session});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _nameCtrl   = TextEditingController();
  bool _isLogin     = true;
  bool _loading     = false;
  String _error     = '';
  bool _passVisible = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    final name  = _nameCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) { setState(() => _error = 'Jaza email na nywila'); return; }
    if (!_isLogin && name.isEmpty) { setState(() => _error = 'Jaza jina lako'); return; }
    if (pass.length < 6) { setState(() => _error = 'Nywila lazima iwe herufi 6+'); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      final data = _isLogin
          ? await ApiService.login(email, pass)
          : await ApiService.register(email, pass, name);
      if (data['success'] == true) {
        final token = data['token'] ?? '';
        final id    = data['id']    ?? '';
        final uname = data['name']  ?? name;
        final prem  = data['is_premium'] == true;
        final exp   = data['subscription_expires'] ?? '';
        await widget.session.saveToken(token);
        await widget.session.saveUser(id, email, uname);
        await widget.session.setPremium(prem, exp);
        if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => MainScreen(session: widget.session)));
      } else {
        setState(() => _error = data['error'] ?? 'Imeshindwa. Jaribu tena.');
      }
    } catch (e) {
      setState(() => _error = 'Hakuna mtandao. Jaribu tena.');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          // Background glow
          Positioned(top: -100, left: -100, child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.red.withOpacity(0.07), Colors.transparent]),
            ),
          )),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 50),

                // Logo
                Center(child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.red.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.2), blurRadius: 30)],
                  ),
                  child: const Icon(Icons.play_circle_filled, color: AppColors.red, size: 46),
                )),
                const SizedBox(height: 20),

                const Center(child: Text('JAYNES MAX TV', style: TextStyle(
                  color: AppColors.red, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4,
                ))),
                const SizedBox(height: 6),
                Center(child: Text(_isLogin ? 'Ingia kwenye akaunti yako' : 'Tengeneza akaunti mpya',
                  style: const TextStyle(color: AppColors.text2, fontSize: 13))),
                const SizedBox(height: 40),

                // Name
                if (!_isLogin) ...[
                  _buildField(controller: _nameCtrl, hint: 'Jina lako kamili', icon: Icons.person_outline),
                  const SizedBox(height: 12),
                ],

                _buildField(controller: _emailCtrl, hint: 'Anwani ya email', icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),

                _buildField(
                  controller: _passCtrl, hint: 'Nywila', icon: Icons.lock_outline,
                  obscure: !_passVisible,
                  suffix: IconButton(
                    icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: AppColors.muted, size: 20),
                    onPressed: () => setState(() => _passVisible = !_passVisible),
                  ),
                ),

                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.red.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),

                // Button
                SizedBox(height: 52, child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isLogin ? 'INGIA' : 'JIANDIKISHE',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2)),
                )),
                const SizedBox(height: 16),

                Center(child: TextButton(
                  onPressed: () => setState(() { _isLogin = !_isLogin; _error = ''; }),
                  child: RichText(text: TextSpan(
                    style: const TextStyle(color: AppColors.text2, fontSize: 13),
                    children: [
                      TextSpan(text: _isLogin ? 'Huna akaunti? ' : 'Una akaunti? '),
                      TextSpan(
                        text: _isLogin ? 'Jiandikishe' : 'Ingia',
                        style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )),
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}
