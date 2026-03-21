import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'live_screen.dart';

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
    final screens = [HomeScreen(user: _user), LiveScreen(user: _user)];
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
