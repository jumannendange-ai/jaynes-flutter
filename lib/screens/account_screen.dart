import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/channel.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'auth_screen.dart';

class AccountScreen extends StatelessWidget {
  final SessionService session;
  const AccountScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('AKAUNTI YANGU')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ─── User card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.red.withOpacity(0.4), width: 2),
                ),
                child: Center(child: Text(
                  s.userName.isNotEmpty ? s.userName[0].toUpperCase() : 'J',
                  style: const TextStyle(color: AppColors.red, fontSize: 26, fontWeight: FontWeight.w900),
                )),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.userName, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(s.userEmail, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: s.isPremium ? AppColors.red.withOpacity(0.1) : AppColors.card2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: s.isPremium ? AppColors.red : AppColors.border),
                  ),
                  child: Text(
                    s.isPremium ? '⭐ PREMIUM' : '🔒 BURE',
                    style: TextStyle(
                      color: s.isPremium ? AppColors.red : AppColors.text2,
                      fontWeight: FontWeight.w800, fontSize: 11,
                    ),
                  ),
                ),
              ])),
            ]),
          ),

          if (s.isPremium && s.subExpires.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.green.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: AppColors.green, size: 16),
                  const SizedBox(width: 8),
                  Text('Subscription inaisha: ${s.subExpires}',
                    style: const TextStyle(color: AppColors.green, fontSize: 12)),
                ]),
              ),
            ),

          const SizedBox(height: 24),

          // ─── Plans ────────────────────────────────────────────────────────
          const _SectionHeader(title: 'CHAGUA MPANGO'),
          const SizedBox(height: 10),
          ...SubscriptionPlan.all.map((plan) => _PlanCard(plan: plan, session: s)),

          const SizedBox(height: 24),

          // ─── WhatsApp ──────────────────────────────────────────────────────
          _ActionButton(
            icon: Icons.chat,
            label: 'Msaada kupitia WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => launchUrl(Uri.parse('https://wa.me/${Constants.whatsappNumber}')),
          ),
          const SizedBox(height: 10),

          // ─── Logout ────────────────────────────────────────────────────────
          _ActionButton(
            icon: Icons.logout,
            label: 'Toka kwenye akaunti',
            color: AppColors.red,
            outline: true,
            onTap: () async {
              await s.logout();
              if (context.mounted) Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => AuthScreen(session: s)), (_) => false);
            },
          ),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 16, color: AppColors.red, margin: const EdgeInsets.only(right: 8)),
    Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.5)),
  ]);
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final SessionService session;
  const _PlanCard({required this.plan, required this.session});

  String _fmt(int n) {
    final s = n.toString().split('').reversed.join();
    return RegExp(r'.{1,3}').allMatches(s).map((m) => m.group(0)!).join(',').split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final popular = plan.id == 'monthly';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: popular ? AppColors.red : AppColors.border, width: popular ? 1.5 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(children: [
          Text(plan.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
          if (popular) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
              child: const Text('MAARUFU', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
            ),
          ],
        ]),
        subtitle: Text(plan.duration, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('TZS ${_fmt(plan.price)}', style: const TextStyle(
            color: AppColors.red, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              final msg = 'Nataka kulipa ${plan.name} (TZS ${plan.price}) - JAYNES MAX TV\nEmail: ${session.userEmail}';
              launchUrl(Uri.parse('https://wa.me/${Constants.whatsappNumber}?text=${Uri.encodeComponent(msg)}'));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.red.withOpacity(0.4)),
              ),
              child: const Text('LIPIA', style: TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool outline;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap, this.outline = false});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: outline
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 18),
            label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
  );
}
