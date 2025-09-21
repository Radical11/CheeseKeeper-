import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/send_page.dart';
import '../dashboard/receive_page.dart';
import '../dashboard/history_page.dart';
import '../profile/profile_page.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({Key? key}) : super(key: key);

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    SendPage(),
    ReceivePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00D4FF),
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF0A0E27),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: "Send"),
          BottomNavigationBarItem(
              icon: Icon(Icons.call_received), label: "Receive"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
