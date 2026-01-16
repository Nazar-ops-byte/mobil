class MoodModel {
  final DateTime date; // Gün bazlı (YYYY-MM-DD)
  final String emoji;

  MoodModel({
    required this.date,
    required this.emoji,
  });

  // Map -> Model
  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      date: DateTime.parse(map['date']),
      emoji: map['emoji'],
    );
  }

  // Model -> Map
  Map<String, dynamic> toMap() {
    return {
      'date': _dayKey(date),
      'emoji': emoji,
    };
  }

  // Aynı gün anahtarı (saat farklarını yok sayar)
  static String _dayKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // Bugün mü?
  bool get isToday {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
}
