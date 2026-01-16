import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/local_storage_service.dart';
import '../utils/animated_route.dart';
import 'add_dump_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  int dumpCount = 0;
  String selectedMood = 'overthink';

  // 🆕 Haftalık içgörü
  String? weeklyInsight;
  String weeklyTitle = '';
  String weeklyEmoji = '😐';

  final TextEditingController _reflectionController = TextEditingController();

  final Map<String, String> moods = {
    'overthink': '😐',
    'stres': '😣',
    'öfke': '😡',
    'kaygı': '😟',
    'mutlu': '🙂',
  };

  @override
  void initState() {
    super.initState();
    _reloadAll();
    _loadWeeklyInsight(); // 🆕
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  // 🔁 TEK NOKTADAN YENİLEME
  Future<void> _reloadAll() async {
    final dumps = await _storageService.getDumps();
    final mood = await _storageService.getMood();

    if (!mounted) return;
    setState(() {
      dumpCount = dumps.length;
      selectedMood = mood;
    });
  }

  Future<void> _selectMood(String moodKey) async {
    setState(() => selectedMood = moodKey);
    await _storageService.saveMood(moodKey);
    _loadWeeklyInsight(); // 🆕 mood değişince içgörü güncellensin
  }

  // =====================
  // 📊 HAFTALIK İÇGÖRÜ
  // =====================

  String _hourBucket(DateTime d) {
    final h = d.hour;
    if (h >= 6 && h < 12) return 'sabah';
    if (h >= 12 && h < 18) return 'öğleden sonra';
    if (h >= 18 && h < 23) return 'akşam';
    return 'gece';
  }

  Future<void> _loadWeeklyInsight() async {
    final dumps = await _storageService.getDumps();
    final now = DateTime.now();

    final last7 = dumps
        .where((d) =>
            d.createdAt.isAfter(now.subtract(const Duration(days: 7))))
        .toList();

    if (last7.isEmpty) {
      if (!mounted) return;
      setState(() {
        weeklyInsight = null;
        weeklyTitle = '';
        weeklyEmoji = '😐';
      });
      return;
    }

    final Map<String, int> moodCount = {};
    final Map<String, int> hourCount = {};

    for (final d in last7) {
      moodCount[d.tag] = (moodCount[d.tag] ?? 0) + 1;
      final bucket = _hourBucket(d.createdAt);
      hourCount[bucket] = (hourCount[bucket] ?? 0) + 1;
    }

    final dominantMood =
        moodCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final dominantHour =
        hourCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    String insight;
    String title;
    String emoji;

    switch (dominantMood) {
      case 'stres':
        emoji = '😣';
        title = 'Biraz yük var gibi';
        insight =
            'Bu hafta stres öne çıktı.\nDumpları çoğunlukla $dominantHour yazmışsın.';
        break;
      case 'öfke':
        emoji = '😡';
        title = 'Yoğun duygular';
        insight =
            'Bu hafta öfke baskın.\nEn çok $dominantHour yazmışsın.';
        break;
      case 'kaygı':
        emoji = '😟';
        title = 'Zihnin tedirgin';
        insight =
            'Kaygı bu hafta belirgin.\nYazmak $dominantHour rahatlatıyor olabilir.';
        break;
      case 'mutlu':
        emoji = '🙂';
        title = 'Daha dengeli';
        insight =
            'Bu hafta daha dengeli görünüyorsun.\nDumplar çoğunlukla $dominantHour.';
        break;
      default:
        emoji = '😐';
        title = 'Zihnin dolu';
        insight =
            'Zihnin bu hafta yoğundu.\nDumpları çoğunlukla $dominantHour yazmışsın.';
    }

    if (!mounted) return;
    setState(() {
      weeklyEmoji = emoji;
      weeklyTitle = title;
      weeklyInsight = insight;
    });
  }

  // =====================
  // UI
  // =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bugün nasılsın?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bugünkü ruh halin: ${moods[selectedMood]}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              children: moods.entries.map((entry) {
                final selected = entry.key == selectedMood;
                return GestureDetector(
                  onTap: () => _selectMood(entry.key),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 🆕 Haftalık içgörü kartı
            if (weeklyInsight != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Bu Haftanın İçgörüsü',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2347),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weeklyEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weeklyTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E2347),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                weeklyInsight!,
                                style: const TextStyle(
                                  color: Color(0xFF3A3A3A),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toplam Dump',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dumpCount.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    AnimatedRoute.bottom(const AddDumpScreen()),
                  );

                  if (result == true) {
                    await _reloadAll();
                    await _loadWeeklyInsight();
                  }
                },
                child: const Text('+ Yeni Dump Yaz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
