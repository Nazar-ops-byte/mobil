import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';

class CreatePinScreen extends StatefulWidget {
  final VoidCallback? onPinCreated;

  const CreatePinScreen({super.key, this.onPinCreated});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final PinService _pinService = PinService();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  String? error;

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pin.length < 4) {
      setState(() => error = 'PIN en az 4 haneli olmalı');
      return;
    }

    if (pin != confirm) {
      setState(() => error = 'PIN’ler eşleşmiyor');
      return;
    }

    await _pinService.setPin(pin);

    if (!mounted) return;

    widget.onPinCreated?.call(); // ✅ AppStartGate güncellesin
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PIN Oluştur'),
        backgroundColor: AppTheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kilitli dump’lar için bir PIN belirle',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN (Tekrar)'),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePin,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
