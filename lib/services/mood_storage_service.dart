import 'package:hive/hive.dart';
import '../models/mood_model.dart';

class MoodStorageService {
  static const String _boxName = 'mood_box';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  /// 📅 Bugünün anahtarını üret (YYYY-MM-DD)
  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 🙂 Bugünün mood’u var mı?
  Future<bool> hasTodayMood() async {
    final box = await _openBox();
    return box.containsKey(_todayKey());
  }

  /// 🙂 Bugünün mood’unu getir
  Future<MoodModel?> getTodayMood() async {
    final box = await _openBox();
    final key = _todayKey();

    if (!box.containsKey(key)) return null;

    final map = Map<String, dynamic>.from(box.get(key));
    return MoodModel.fromMap(map);
  }

  /// 💾 Bugünün mood’unu kaydet / güncelle
  Future<void> saveTodayMood(String emoji) async {
    final box = await _openBox();
    final now = DateTime.now();

    final mood = MoodModel(
      date: now,
      emoji: emoji,
    );

    await box.put(_todayKey(), mood.toMap());
  }

  /// 📊 Son N günün mood’ları (ileride grafik için)
  Future<List<MoodModel>> getRecentMoods(int days) async {
    final box = await _openBox();
    final List<MoodModel> list = [];

    for (final key in box.keys) {
      final map = box.get(key);
      if (map == null) continue;

      final mood = MoodModel.fromMap(Map<String, dynamic>.from(map));
      list.add(mood);
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(days).toList();
  }
}
