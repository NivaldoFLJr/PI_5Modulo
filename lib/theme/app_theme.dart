import 'package:flutter/material.dart';

class AppTheme {
  // ===== CORES PRINCIPAIS =====

  static const Color primary = Color(0xFF88CDFF);
  static const Color primaryDark = Color(0xFF5BB8FF);
  static const Color primaryDeep = Color(0xFF3A9EE8);

  // ===== BACKGROUNDS =====

  static const Color background = Color(0xFFF0F8FF);
  static const Color surface = Color(0xFFFFFFFF);

  // ===== CORES AUXILIARES =====

  static const Color lightBlue = Color(0xFFEEF6FF);
  static const Color orangeLight = Color(0xFFFFF3EE);
  static const Color greenLight = Color(0xFFF4FEEE);

  // ===== TEXTO =====

  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textMuted = Color(0xFF6B8CAE);

  // ===== BORDAS =====

  static const Color cardBorder = Color(0xFFD0E9FF);

  // ===== STATUS =====

  static const Color green = Color(0xFF2ECC71);
  static const Color orange = Color(0xFFE8974A);
  static const Color red = Color(0xFFE74C3C);

  // ===== TEMA =====

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: background,

        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: primaryDark,
          surface: surface,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryDeep,
          unselectedItemColor: textMuted,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDeep,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: cardBorder,
            ),
          ),
        ),
      );

  // ===== DECORAÇÕES =====

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder,
        ),
      );

  static BoxDecoration get metricDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      );

  // ===== TEXT STYLES =====

  static const TextStyle metricLabelStyle = TextStyle(
    color: Colors.white70,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle metricValueStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    color: textMuted,
    fontSize: 12,
  );

  static const TextStyle cardValueStyle = TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );

  static const TextStyle greenTextStyle = TextStyle(
    color: green,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle defaultTextStyle = TextStyle(
    color: textPrimary,
    fontSize: 14,
  );

  static const TextStyle boldTextStyle = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}