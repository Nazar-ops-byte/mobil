import 'package:flutter/material.dart';

import '../models/dump_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  Map<String, List<DumpModel>> _groupedDumps = {};

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    // ✅ Serviste OLAN metot
    final dumps = await _storageService.getDumps();

    final Map<String, List<DumpModel>> grouped = {};

    for (final dump in dumps) {
      final key =
          '${dump.createdAt.year}-${dump.createdAt.month}-${dump.createdAt.day}';
      grouped.putIfAbsent(key, () => []).add(dump);
    }

    // ✅ Tarihe göre sıralama (yeniden eskiye)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final Map<String, List<DumpModel>> sortedGrouped = {
      for (final k in sortedKeys) k: grouped[k]!
    };

    if (!mounted) return;
    setState(() => _groupedDumps = sortedGrouped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Arşiv'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadArchive,
        child: _groupedDumps.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'Henüz dump yok',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: _groupedDumps.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map(
                        (dump) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dump.text,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
