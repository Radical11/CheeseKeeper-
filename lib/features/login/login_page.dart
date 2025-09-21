import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  String? _error;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CheeseKeeper Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _error,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                User? user = await StorageService.loadUser();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/main');
                } else {
                  // Handle the case where the user is null, e.g., show an error message
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/setup'),
              child: const Text('New user? Setup CheeseKeeper'),
            ),
          ],
        ),
      ),
    );
  }
}
