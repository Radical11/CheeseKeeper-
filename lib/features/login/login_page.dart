import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/crypto_service.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _isLogging = false;

  Future<void> _handleLogin() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Password required');
      return;
    }

    setState(() {
      _isLogging = true;
      _error = null;
    });

    try {
      // Load existing user profile
      final existing = await StorageService.loadUser();
      if (existing == null || existing.encryptedPrivateKey == null) {
        setState(() {
          _error = 'No wallet found. Please run setup first.';
        });
        return;
      }

      // Attempt to decrypt stored private key
      final enc = json.decode(existing.encryptedPrivateKey!);
      final priv = CryptoService.decryptAES(enc['ciphertext'], enc['iv'], password);
      if (priv == null) {
        setState(() => _error = 'Incorrect password');
        return;
      }

      // Successful decryption means password is valid; proceed to main
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
      return;
    } catch (e) {
      setState(() => _error = 'Login error: ${e.toString()}');
    } finally {
      setState(() => _isLogging = false);
    }
  }

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
              onPressed: _isLogging ? null : () => _handleLogin(),
              child: _isLogging 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      Text('Logging in...')
                    ],
                  )
                : const Text('Login'),
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
