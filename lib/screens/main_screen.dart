import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'live_screen.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  final SessionService session;
  const MainScreen({super.key, required this.session});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(session: widget.session),
      CategoriesScreen(session: widget.session),
      LiveScreen(session: widget.session),
      AccountScreen(session: widget.session),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        activeIcon: Icon(Icons.home),        label: 'Nyumbani'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),   activeIcon: Icon(Icons.grid_view),   label: 'Makundi'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer_outlined),activeIcon: Icon(Icons.sports_soccer),label: 'Live'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),       activeIcon: Icon(Icons.person),      label: 'Akaunti'),
          ],
        ),
      ),
    );
  }
}
