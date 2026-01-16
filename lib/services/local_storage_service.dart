import 'package:hive/hive.dart';
import '../models/dump_model.dart';

class LocalStorageService {
  // 🔹 Box adları
  static const String _dumpBoxName = 'dumps';
  static const String _prefsBoxName = 'app_prefs';

  // 🔹 Keys
  static const String _moodKey = 'current_mood';

  Box? _dumpBox;
  Box? _prefsBox;

  // =====================
  // 📦 BOX AÇMA (GÜVENLİ)
  // =====================

  Future<Box> _openDumpBox() async {
    if (_dumpBox != null && _dumpBox!.isOpen) {
      return _dumpBox!;
    }
    _dumpBox = await Hive.openBox(_dumpBoxName);
    return _dumpBox!;
  }

  Future<Box> _openPrefsBox() async {
    if (_prefsBox != null && _prefsBox!.isOpen) {
      return _prefsBox!;
    }
    _prefsBox = await Hive.openBox(_prefsBoxName);
    return _prefsBox!;
  }

  // =====================
  // 📝 DUMP İŞLEMLERİ
  // =====================

  Future<void> addDump(DumpModel dump) async {
    final box = await _openDumpBox();
    await box.put(dump.id, dump.toMap());
  }

  Future<List<DumpModel>> getDumps() async {
    final box = await _openDumpBox();

    return box.values
        .where((e) => e is Map)
        .map((e) => DumpModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updateDump(DumpModel dump) async {
    final box = await _openDumpBox();
    await box.put(dump.id, dump.toMap());
  }

  Future<void> deleteDump(String id) async {
    final box = await _openDumpBox();
    await box.delete(id);
  }

  // =====================
  // 📦 ARŞİV
  // =====================

  Future<List<DumpModel>> getArchivedDumps() async {
    final box = await _openDumpBox();

    final all = box.values
        .where((e) => e is Map)
        .map((e) => DumpModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    return all
        .where((d) => d.isLocked || d.isExpired)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // =====================
  // 🙂 MOOD
  // =====================

  Future<void> saveMood(String mood) async {
    final box = await _openPrefsBox();
    await box.put(_moodKey, mood);
  }

  Future<String> getMood() async {
    final box = await _openPrefsBox();
    return box.get(_moodKey, defaultValue: 'overthink');
  }

  // =====================
  // 📝 BASİT KEY–VALUE
  // =====================

  Future<void> saveSimpleValue(String key, String value) async {
    final box = await _openPrefsBox();
    await box.put(key, value);
  }

  Future<String?> getSimpleValue(String key) async {
    final box = await _openPrefsBox();
    return box.get(key);
  }
}
