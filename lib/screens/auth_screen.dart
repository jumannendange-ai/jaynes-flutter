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

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _nameCtrl     = TextEditingController();
  bool _isLogin       = true;
  bool _loading       = false;
  String _error       = '';
  bool _passVisible   = false;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    final name  = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Jaza email na nywila');
      return;
    }
    if (!_isLogin && name.isEmpty) {
      setState(() => _error = 'Jaza jina lako');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Nywila lazima iwe herufi 6+');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    try {
      final data = _isLogin
          ? await ApiService.login(email, pass)
          : await ApiService.register(email, pass, name);

      if (data['success'] == true) {
        final token = data['token'] ?? '';
        final id    = data['id']    ?? '';
        final uname = data['name'] ?? name;
        final prem  = data['is_premium'] == true;
        final exp   = data['subscription_expires'] ?? '';
        await widget.session.saveToken(token);
        await widget.session.saveUser(id, email, uname);
        await widget.session.setPremium(prem, exp);
        if (mounted) {
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => MainScreen(session: widget.session)));
        }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Center(child: Text('JAYNES', style: TextStyle(
                color: AppColors.accent, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 6,
              ))),
              const Center(child: Text('MAX TV', style: TextStyle(
                color: AppColors.text, fontSize: 22, letterSpacing: 8,
              ))),
              const SizedBox(height: 48),

              // Name field
              if (!_isLogin) ...[
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    hintText: 'Jina lako',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 12),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: !_passVisible,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Nywila',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                  suffixIcon: IconButton(
                    icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: AppColors.muted),
                    onPressed: () => setState(() => _passVisible = !_passVisible),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Error
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent2.withOpacity(0.3)),
                  ),
                  child: Text(_error, style: const TextStyle(color: AppColors.accent2, fontSize: 13)),
                ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(_isLogin ? 'INGIA' : 'JIANDIKISHE',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle
              Center(
                child: TextButton(
                  onPressed: () => setState(() { _isLogin = !_isLogin; _error = ''; }),
                  child: Text(
                    _isLogin ? 'Huna akaunti? Jiandikishe' : 'Una akaunti? Ingia',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
