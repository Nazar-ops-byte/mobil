import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PinService _pinService = PinService();

  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  Future<void> _checkLockStatus() async {
    final has = await _pinService.hasPin();
    if (!mounted) return;
    setState(() => _hasPassword = has);
  }

  // 🔑 Şifre oluştur / değiştir
  Future<void> _setPassword() async {
    final reminder = ScaffoldMessenger.of(context);
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_hasPassword ? 'Şifreyi Değiştir' : 'Şifre Oluştur'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Yeni şifre',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await _pinService.setPin(result);
    await _checkLockStatus();

    reminder.showSnackBar(
      SnackBar(
        content: Text(
          _hasPassword
              ? 'Şifre güncellendi'
              : 'Uygulama kilidi oluşturuldu',
        ),
      ),
    );
  }

  // 🗑️ Kilidi kaldır
  Future<void> _removePassword() async {
    final reminder = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kilit Kaldırılsın mı?'),
          content: const Text(
            'Uygulama kilidi tamamen kaldırılacak.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kaldır'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _pinService.clearPin();
    await _checkLockStatus();

    reminder.showSnackBar(
      const SnackBar(
        content: Text('Uygulama kilidi kaldırıldı'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gizlilik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // 🔒 Kilit durumu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Uygulama Kilidi',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  Text(
                    _hasPassword ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      color: _hasPassword
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔑 Şifre oluştur / değiştir
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _setPassword,
                child: Text(
                  _hasPassword ? 'Şifreyi Değiştir' : 'Şifre Oluştur',
                ),
              ),
            ),

            if (_hasPassword) ...[
              const SizedBox(height: 12),

              // 🗑️ Kilidi kaldır
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _removePassword,
                  child: const Text('Kilidi Kaldır'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
