import 'package:hive_flutter/hive_flutter.dart';

class AppLockService {
  final _box = Hive.box('app_prefs');

  Future<bool> verifyPassword(String input) async {
    final saved = _box.get('pin');
    return saved == input;
  }

  // ❌ GLOBAL KİLİT YOK
  Future<bool> isUnlocked() async {
    return false;
  }
}
