import 'dart:io';

import 'package:flutter/material.dart';
import '../models/dump_model.dart';
import '../services/local_storage_service.dart';
import 'dump_detail_screen.dart';
import 'unlock_screen.dart';
import '../utils/animated_route.dart';
import 'add_dump_screen.dart'; // 🔥 EKLENDİ

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _storage = LocalStorageService();

  List<DumpModel> _dumps = [];

  @override
  void initState() {
    super.initState();
    _loadDumps();
  }

  Future<void> _loadDumps() async {
    final data = await _storage.getDumps();
    if (!mounted) return;
    setState(() => _dumps = data);
  }

  // ➕ YENİ DUMP EKLE
  Future<void> _openAddDump() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDumpScreen()),
    );

    if (result is DumpModel && mounted) {
      await _loadDumps(); // 🔥 ANINDA LİSTEYİ YENİLE
    }
  }

  // 🙂 TAG → EMOJI
  String _emojiFromTag(String tag) {
    switch (tag.toLowerCase()) {
      case 'overthink':
        return '😐';
      case 'stres':
        return '😣';
      case 'öfke':
        return '😡';
      case 'kaygı':
        return '😟';
      default:
        return '😐';
    }
  }

  // 🔑 DUMP AÇ
  Future<void> _openDump(DumpModel dump) async {
    if (dump.isLocked) {
      final unlocked = await Navigator.push(
        context,
        AnimatedRoute.fade(
          UnlockScreen(
            onUnlocked: () {
              Navigator.pop(context, true);
            },
          ),
        ),
      );

      if (unlocked != true) return;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      AnimatedRoute.slide(
        DumpDetailScreen(dump: dump),
      ),
    );

    // 🔥 DETAYDAN DÖNÜNCE TÜM LİSTEYİ YENİLE
    if (!mounted) return;
    await _loadDumps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overthink Dump'),
        automaticallyImplyLeading: false,
      ),

      // 🔥 YENİ EKLENDİ
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDump,
        child: const Icon(Icons.add),
      ),

      body: _dumps.isEmpty
          ? const Center(
              child: Text(
                'Henüz dump yok.\nYeni bir dump ekleyebilirsin.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dumps.length,
              itemBuilder: (context, index) {
                final dump = _dumps[index];
                final locked = dump.isLocked;

                return GestureDetector(
                  onTap: () => _openDump(dump),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: locked
                          ? const Icon(Icons.lock, size: 28)
                          : (dump.imagePath != null &&
                                  File(dump.imagePath!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(dump.imagePath!),
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  _emojiFromTag(dump.tag),
                                  style:
                                      const TextStyle(fontSize: 24),
                                )),
                      title: locked
                          ? const Text(
                              'Kilitli dump',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600),
                            )
                          : Text(dump.tag),
                      subtitle: locked
                          ? const Text(
                              'İçerik gizlendi',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Text(
                              dump.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing:
                          locked ? const Icon(Icons.chevron_right) : null,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
