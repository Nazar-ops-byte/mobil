import 'dart:io';

import 'package:flutter/material.dart';

import '../models/dump_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'add_dump_screen.dart';
import 'enter_pin_screen.dart';

class DumpListScreen extends StatefulWidget {
  const DumpListScreen({super.key});

  @override
  State<DumpListScreen> createState() => _DumpListScreenState();
}

class _DumpListScreenState extends State<DumpListScreen> {
  final LocalStorageService _storage = LocalStorageService();

  late Future<List<DumpModel>> _dumpFuture;

  @override
  void initState() {
    super.initState();
    _dumpFuture = _storage.getDumps();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _dumpFuture = _storage.getDumps(); // 🔥 YENİ FUTURE
    });
  }

  String _formatDate(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  // ➕ DUMP EKLE
  Future<void> _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDumpScreen()),
    );

    // 🔥 SADECE GERÇEKTEN DUMP DÖNERSE
    if (result is DumpModel && mounted) {
      _refresh();
    }
  }

  Future<void> _deleteDump(DumpModel dump) async {
    if (dump.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔒 Kilitli dump silinemez')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin mi?'),
        content: const Text(
          'Bu düşünce kalıcı olarak silinecek.\nGeri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bırak'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _storage.deleteDump(dump.id);
      _refresh();
    }
  }

  Future<void> _toggleLock(DumpModel dump) async {
    final updated = dump.copyWith(isLocked: !dump.isLocked);
    await _storage.updateDump(updated);
    _refresh();
  }

  Future<void> _openDetail(DumpModel dump) async {
    if (dump.isLocked) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const EnterPinScreen()),
      );

      if (ok != true) return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(dump.mood, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dump.tag,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleLock(dump),
                  icon: Icon(
                    dump.isLocked ? Icons.lock : Icons.lock_open,
                  ),
                ),
                IconButton(
                  onPressed: dump.isLocked
                      ? null
                      : () {
                          Navigator.pop(context);
                          _deleteDump(dump);
                        },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(dump.createdAt),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),

            if (dump.imagePath != null &&
                File(dump.imagePath!).existsSync())
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(dump.imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Text(
              dump.text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                height: 1.4,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );

    _refresh(); // 🔥 DETAY KAPANINCA DA YENİLE
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Dump',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _openAdd,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Yeni Dump',
          ),
        ],
      ),
      body: FutureBuilder<List<DumpModel>>(
        future: _dumpFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final dumps = snapshot.data ?? [];

          if (dumps.isEmpty) {
            return const Center(
              child: Text(
                'Henüz dump yok.\nSağ üstten + ile ekleyebilirsin.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textSecondary, height: 1.4),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dumps.length,
            itemBuilder: (context, index) {
              final dump = dumps[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () => _openDetail(dump),
                  leading: dump.imagePath != null &&
                          File(dump.imagePath!).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(dump.imagePath!),
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          dump.mood,
                          style: const TextStyle(fontSize: 24),
                        ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dump.tag,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (dump.isLocked)
                        const Icon(Icons.lock, size: 16),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        dump.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(dump.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed:
                        dump.isLocked ? null : () => _deleteDump(dump),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
