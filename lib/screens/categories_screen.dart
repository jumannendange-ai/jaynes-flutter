import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  final SessionService session;
  const CategoriesScreen({super.key, required this.session});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _cats = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cats = await ApiService.fetchCategories();
    setState(() { _cats = cats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('MAKUNDI')),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2,
                ),
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final cat = _cats[i];
                  return GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(cat['name'] ?? ''), backgroundColor: AppColors.card),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(fit: StackFit.expand, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: cat['image'] != null && cat['image'].toString().isNotEmpty
                              ? Opacity(
                                  opacity: 0.5,
                                  child: CachedNetworkImage(imageUrl: cat['image'], fit: BoxFit.cover),
                                )
                              : Container(color: AppColors.card2),
                        ),
                        Center(
                          child: Text(cat['name'] ?? '',
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
