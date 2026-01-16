import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 🌌 Starry Night – Backgrounds
  static const Color background = Color(0xFF0B1D3A); // Derin gece laciverti
  static const Color card = Color(0xFF1C3A63);       // Dalgalı mavi yüzey

  // ⭐ Starry Night – Accents (SOFT)
  static const Color primary = Color(0xFFE6B65C);   // ⭐ KISILMIŞ YILDIZ SARISI
  static const Color secondary = Color(0xFF5DA9E9); // Gökyüzü mavisi
  static const Color accent = Color(0xFF9BBFE0);    // Yumuşak açık mavi

  // ✍️ Text (kırık beyaz)
  static const Color textPrimary = Color(0xFFF6F1E1);
  static const Color textSecondary = Color(0xFFD6DCE8);
  static const Color textMuted = Color(0xFF9FB3C8);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    cardColor: card,

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textMuted),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary, // ⭐ artık daha soft
      foregroundColor: background,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: background,
        backgroundColor: primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: card,
      selectedColor: secondary,
      labelStyle: TextStyle(color: textSecondary),
      secondaryLabelStyle: TextStyle(color: background),
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
  );
}
