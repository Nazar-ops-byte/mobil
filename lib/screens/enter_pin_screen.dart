import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final _pinService = PinService();
  final _controller = TextEditingController();
  String? error;

  Future<void> _checkPin() async {
    final input = _controller.text.trim();
    final ok = await _pinService.verifyPin(input);

    if (!ok) {
      setState(() => error = 'PIN yanlış');
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true); // BAŞARILI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PIN Gir'),
        backgroundColor: AppTheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Bu dump kilitli 🔒',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN',
              ),
            ),

            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkPin,
                child: const Text('Aç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
