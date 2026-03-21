import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'live_screen.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainScreen({super.key, required this.user});
  @override State<MainScreen> createState() => _State();
}

class _State extends State<MainScreen> {
  int _i = 0;
  late Map<String, dynamic> _user;
  @override
  void initState() { super.initState(); _user = Map.from(widget.user); }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[HomeScreen(user: _user), LiveScreen(user: _user)];
    return Scaffold(
      body: IndexedStack(index: _i, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (i) => setState(() => _i = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Nyumbani'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv_rounded), label: 'Live'),
        ],
      ),
    );
  }
}
