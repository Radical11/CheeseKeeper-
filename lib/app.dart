import 'package:flutter/material.dart';
import 'features/login/login_page.dart';
import 'features/setup/setup_page.dart';
import 'features/navigation/main_nav_shell.dart';

class CheeseKeeperApp extends StatelessWidget {
  const CheeseKeeperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheeseKeeper',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A0E27),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/setup': (_) => const SetupPage(),
        '/main': (_) => const MainNavShell(), // Bottom nav only here
      },
    );
  }
}