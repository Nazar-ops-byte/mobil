import 'package:hive_flutter/hive_flutter.dart';

class PinService {
  static const String _boxName = 'settings';
  static const String _pinKey = 'user_pin';

  Box? _cachedBox;

  Future<Box> _box() async {
    if (_cachedBox != null) return _cachedBox!;
    _cachedBox = await Hive.openBox(_boxName);
    return _cachedBox!;
  }

  /// PIN var mı?
  Future<bool> hasPin() async {
    final box = await _box();
    return box.containsKey(_pinKey);
  }

  /// PIN kaydet
  Future<void> setPin(String pin) async {
    final box = await _box();
    await box.put(_pinKey, pin);
  }

  /// PIN doğrula
  Future<bool> verifyPin(String pin) async {
    final box = await _box();
    final savedPin = box.get(_pinKey);
    return savedPin != null && savedPin == pin;
  }

  /// PIN değiştir
  Future<void> changePin(String newPin) async {
    final box = await _box();
    await box.put(_pinKey, newPin);
  }

  /// PIN sıfırla (Şifremi Unuttum)
  Future<void> resetPin() async {
    final box = await _box();
    await box.delete(_pinKey);
  }

  /// GERİYE UYUMLULUK (SettingsScreen için)
  Future<void> clearPin() async {
    await resetPin();
  }
}
