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
        color: AppColors.red,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.red))
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3,
                ),
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final cat = _cats[i];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(fit: StackFit.expand, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: cat['image'] != null && cat['image'].toString().isNotEmpty
                              ? Opacity(
                                  opacity: 0.4,
                                  child: CachedNetworkImage(imageUrl: cat['image'], fit: BoxFit.cover),
                                )
                              : Container(color: AppColors.card2),
                        ),
                        // Gradient overlay
                        Container(decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        )),
                        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.grid_view, color: AppColors.red, size: 28),
                          const SizedBox(height: 6),
                          Text(cat['name'] ?? '',
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 13),
                            textAlign: TextAlign.center, maxLines: 2),
                        ])),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
