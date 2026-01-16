class DumpModel {
  final String id;
  final String text;
  final String tag;
  final DateTime createdAt;
  final bool isLocked;
  final DateTime? autoDeleteAt;
  final String mood;

  // 📸 FOTOĞRAF YOLU (opsiyonel)
  final String? imagePath;

  DumpModel({
    required this.id,
    required this.text,
    required this.tag,
    required this.createdAt,
    this.isLocked = false,
    this.autoDeleteAt,
    this.mood = '😐',
    this.imagePath,
  });

  // 🔁 Model → Map (Local storage için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'isLocked': isLocked,
      'autoDeleteAt': autoDeleteAt?.toIso8601String(),
      'mood': mood,
      'imagePath': imagePath, // ✅
    };
  }

  // 🔁 Map → Model
  factory DumpModel.fromMap(Map<String, dynamic> map) {
    return DumpModel(
      id: map['id'] as String,
      text: map['text'] as String,
      tag: map['tag'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      isLocked: map['isLocked'] == true, // 🔒 güvenli okuma
      autoDeleteAt: map['autoDeleteAt'] != null
          ? DateTime.parse(map['autoDeleteAt'])
          : null,
      mood: map['mood'] ?? '😐',
      imagePath: map['imagePath'], // ✅
    );
  }

  // 🧩 Güncelleme kopyası
  DumpModel copyWith({
    String? id,
    String? text,
    String? tag,
    DateTime? createdAt,
    bool? isLocked,
    DateTime? autoDeleteAt,
    String? mood,
    String? imagePath,
  }) {
    return DumpModel(
      id: id ?? this.id,
      text: text ?? this.text,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
      autoDeleteAt: autoDeleteAt ?? this.autoDeleteAt,
      mood: mood ?? this.mood,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // 🔁 Kilit durumunu tersine çevir (UI için ÇOK PRATİK)
  DumpModel toggleLock() {
    return copyWith(isLocked: !isLocked);
  }

  // ⏱️ Süresi dolmuş mu?
  bool get isExpired {
    if (autoDeleteAt == null) return false;
    return DateTime.now().isAfter(autoDeleteAt!);
  }
}
