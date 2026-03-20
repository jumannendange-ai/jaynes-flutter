import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/channel.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'auth_screen.dart';

class AccountScreen extends StatefulWidget {
  final SessionService session;
  const AccountScreen({super.key, required this.session});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('AKAUNTI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ─── User card ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 36, backgroundColor: AppColors.accent.withOpacity(0.15),
                child: Text(s.userName.isNotEmpty ? s.userName[0].toUpperCase() : 'J',
                  style: const TextStyle(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(s.userName, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(s.userEmail, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: s.isPremium ? AppColors.accent.withOpacity(0.1) : AppColors.accent2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: s.isPremium ? AppColors.accent : AppColors.accent2, width: 1),
                ),
                child: Text(
                  s.isPremium ? '✅ PREMIUM' : '🔒 BURE',
                  style: TextStyle(color: s.isPremium ? AppColors.accent : AppColors.accent2,
                    fontWeight: FontWeight.bold),
                ),
              ),
              if (s.isPremium && s.subExpires.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Inaisha: ${s.subExpires}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ),
            ]),
          ),

          const SizedBox(height: 20),

          // ─── Plans ───────────────────────────────────────────────────────────
          const Text('CHAGUA MPANGO', style: TextStyle(
            color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2,
          )),
          const SizedBox(height: 10),

          ...SubscriptionPlan.all.map((plan) => _PlanCard(plan: plan, session: s)),

          const SizedBox(height: 20),

          // ─── WhatsApp support ─────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://wa.me/${Constants.whatsappNumber}')),
            icon: const Icon(Icons.chat, color: AppColors.green),
            label: const Text('Msaada WhatsApp', style: TextStyle(color: AppColors.green)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.green),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Logout ───────────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              await s.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => AuthScreen(session: s)),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: AppColors.accent2),
            label: const Text('Toka', style: TextStyle(color: AppColors.accent2)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final SessionService session;
  const _PlanCard({required this.plan, required this.session});

  @override
  Widget build(BuildContext context) {
    final popular = plan.id == 'monthly';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: popular ? AppColors.gold : AppColors.border, width: popular ? 1.5 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Row(children: [
          Text(plan.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          if (popular) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
              child: const Text('MAARUFU', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        subtitle: Text(plan.duration, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('TZS ${_fmt(plan.price)}',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                final msg = 'Nataka kulipa ${plan.name} (TZS ${plan.price}) - JAYNES MAX TV\nEmail: ${session.userEmail}';
                launchUrl(Uri.parse('https://wa.me/${Constants.whatsappNumber}?text=${Uri.encodeComponent(msg)}'));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: const Text('LIPIA', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString().split('').reversed.join();
    final groups = RegExp(r'.{1,3}').allMatches(s).map((m) => m.group(0)!).join(',');
    return groups.split('').reversed.join();
  }
}
