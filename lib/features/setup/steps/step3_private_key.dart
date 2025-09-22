import 'package:flutter/material.dart';

class Step3PrivateKey extends StatefulWidget {
  final VoidCallback? onNext;
  const Step3PrivateKey({Key? key, this.onNext}) : super(key: key);

  @override
  State<Step3PrivateKey> createState() => _Step3PrivateKeyState();
}

class _Step3PrivateKeyState extends State<Step3PrivateKey> {
  @override
  void initState() {
    super.initState();
    // Private key already generated in previous step.
    // Auto-advance after a short delay to keep UX predictable.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.onNext != null) widget.onNext!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Securing your private key...'),
        ],
      ),
    );
  }
}
