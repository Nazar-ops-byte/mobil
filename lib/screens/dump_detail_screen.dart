import 'dart:io';

import 'package:flutter/material.dart';
import '../models/dump_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class DumpDetailScreen extends StatefulWidget {
  final DumpModel dump;

  const DumpDetailScreen({super.key, required this.dump});

  @override
  State<DumpDetailScreen> createState() => _DumpDetailScreenState();
}

class _DumpDetailScreenState extends State<DumpDetailScreen> {
  final LocalStorageService _storage = LocalStorageService();

  late DumpModel _dump;

  @override
  void initState() {
    super.initState();
    _dump = widget.dump;
    _reloadFromStorage(); // 🔥 GÜNCEL VERİYİ ÇEK
  }

  Future<void> _reloadFromStorage() async {
    final all = await _storage.getDumps();
    final latest =
        all.firstWhere((d) => d.id == widget.dump.id, orElse: () => _dump);

    if (!mounted) return;
    setState(() => _dump = latest);
  }

  // 🔒 KİLİT AÇ / KAPAT
  Future<void> _toggleLock() async {
    final updated = _dump.copyWith(isLocked: !_dump.isLocked);
    await _storage.updateDump(updated);

    setState(() => _dump = updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isLocked
              ? 'Dump kilitlendi'
              : 'Dump kilidi açıldı',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🔥 EKRANDAN ÇIKARKEN GÜNCEL DUMP'I GERİ DÖN
      onWillPop: () async {
        Navigator.pop(context, _dump);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          title: const Text('Dump'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dump);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _dump.isLocked ? Icons.lock : Icons.lock_open,
              ),
              onPressed: _toggleLock,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dump.tag,
                style: const TextStyle(
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 12),

              /// 📸 FOTOĞRAF (VARSA)
              if (_dump.imagePath != null &&
                  File(_dump.imagePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_dump.imagePath!),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _dump.text,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
