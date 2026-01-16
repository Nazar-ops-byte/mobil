import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final LocalStorageService _storage = LocalStorageService();

  Map<String, int> moodCounts = {};
  Map<String, int> dailyCounts = {}; // son 7 gün (yyyy-MM-dd)
  bool loading = true;

  int totalDumpCount = 0;
  String dominantMood = '';
  String dominantHour = '';
  String dominantDay = '';

  final Map<String, String> moodEmojis = {
    'overthink': '😐',
    'stres': '😣',
    'öfke': '😡',
    'kaygı': '😟',
    'mutlu': '🙂',
  };

  late List<String> orderedDayKeys; // 🔥 kritik

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  // ======================
  // 📊 VERİ HESAPLAMA
  // ======================
  Future<void> _loadInsights() async {
    final dumps = await _storage.getDumps();
    final now = DateTime.now();

    final last7Days = dumps.where(
      (d) => d.createdAt.isAfter(now.subtract(const Duration(days: 7))),
    );

    final Map<String, int> counts = {};
    final Map<String, int> hourCounts = {};
    final Map<String, int> dayMap = {};

    // 🔥 Son 7 günü sırayla oluştur
    orderedDayKeys = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      dayMap[key] = 0;
      orderedDayKeys.add(key);
    }

    for (final d in last7Days) {
      counts[d.tag] = (counts[d.tag] ?? 0) + 1;

      final h = d.createdAt.hour;
      final bucket = h < 12
          ? 'Sabah'
          : h < 18
              ? 'Öğleden Sonra'
              : h < 23
                  ? 'Akşam'
                  : 'Gece';

      hourCounts[bucket] = (hourCounts[bucket] ?? 0) + 1;

      final key = _dateKey(d.createdAt);
      dayMap[key] = (dayMap[key] ?? 0) + 1;
    }

    if (!mounted) return;

    setState(() {
      moodCounts = counts;
      dailyCounts = dayMap;
      totalDumpCount = last7Days.length;

      if (counts.isNotEmpty) {
        dominantMood =
            counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      if (hourCounts.isNotEmpty) {
        dominantHour =
            hourCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      if (dayMap.isNotEmpty) {
        final topKey =
            dayMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        dominantDay = _dayNameFromKey(topKey);
      }

      loading = false;
    });
  }

  // ======================
  // 🗓️ TARİH YARDIMCI
  // ======================
  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dayNameFromKey(String key) {
    final parts = key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];

    return days[date.weekday - 1];
  }

  // ======================
  // 🧾 ÖZET KART
  // ======================
  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ======================
  // 🥧 PIE CHART
  // ======================
  List<PieChartSectionData> _buildSections() {
    final total = moodCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [];

    return moodCounts.entries.map((entry) {
      final percent = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percent.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        color: AppTheme.primary.withOpacity(0.75),
        badgeWidget:
            Text(moodEmojis[entry.key] ?? '', style: const TextStyle(fontSize: 18)),
        badgePositionPercentageOffset: 1.25,
      );
    }).toList();
  }

  // ======================
  // 📊 BAR CHART
  // ======================
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(orderedDayKeys.length, (index) {
      final value = dailyCounts[orderedDayKeys[index]] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value == 0 ? 0.3 : value.toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: AppTheme.primary,
          ),
        ],
      );
    });
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    final maxY = dailyCounts.values.isEmpty
        ? 5.0
        : dailyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('İçgörüler')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF6D8),
                        borderRadius: BorderRadius.circular(18)),
                    child: const Text(
                      'Bu ekran, son 7 gün içinde yazdığın dumplara göre otomatik oluşturulan içgörüleri gösterir.',
                      style: TextStyle(
                          color: Color(0xFF1E2347),
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _summaryCard('Son 7 Gün', totalDumpCount.toString()),
                      const SizedBox(width: 10),
                      _summaryCard(
                          'Baskın Ruh',
                          dominantMood.isEmpty
                              ? '-'
                              : '${moodEmojis[dominantMood]} $dominantMood'),
                      const SizedBox(width: 10),
                      _summaryCard('En Aktif Zaman',
                          dominantHour.isEmpty ? '-' : dominantHour),
                    ],
                  ),

                  const SizedBox(height: 28),

                  if (moodCounts.isNotEmpty)
                    SizedBox(
                      height: 260,
                      child: PieChart(
                        PieChartData(
                          sections: _buildSections(),
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  const Text('Haftalık Dump Dağılımı',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY,
                        barGroups: _buildBarGroups(),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= orderedDayKeys.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  _dayNameFromKey(orderedDayKeys[index])
                                      .substring(0, 3),
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (dominantDay.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        '📌 Bu hafta en çok $dominantDay yazmışsın.\n'
                        'Bu günlerde zihnin daha aktif görünüyor.',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
