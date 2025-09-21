import 'package:flutter/material.dart';

class Step6Complete extends StatefulWidget {
  const Step6Complete({Key? key}) : super(key: key);

  @override
  State<Step6Complete> createState() => _Step6CompleteState();
}

class _Step6CompleteState extends State<Step6Complete> {
  bool _waiting = true;

  @override
  void initState() {
    super.initState();
    _waitForESP32Confirmation();
  }

  Future<void> _waitForESP32Confirmation() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _waiting = false;
    });
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _waiting
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text("Waiting for ESP32 confirmation..."),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 64),
                SizedBox(height: 24),
                Text(
                  "Setup Complete!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text("You can now log in to CheeseKeeper."),
              ],
            ),
    );
  }
}
