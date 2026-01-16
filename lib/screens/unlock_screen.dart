import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';
import 'create_pin_screen.dart';

class UnlockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const UnlockScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final PinService _pinService = PinService();
  final TextEditingController _controller = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await _pinService.verifyPin(input);

    if (!mounted) return;

    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _error = 'Şifre yanlış';
        _loading = false;
      });
    }
  }

  /// 🔁 ŞİFREMİ UNUTTUM
  Future<void> _forgotPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Şifreyi Sıfırla'),
          content: const Text(
            'Uygulama kilidi kaldırılacak.\n'
            'Kilitli dump’lar gizli kalmaya devam eder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Devam Et'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _pinService.resetPin();

    if (!mounted) return;

    // 🔁 Yeni PIN oluşturma ekranı
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePinScreen(
          onPinCreated: widget.onUnlocked,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Kilitli içerik',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'PIN',
                ),
                onSubmitted: (_) => _submit(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Kilidi Aç'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _forgotPin,
                child: const Text(
                  'Şifremi unuttum',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
