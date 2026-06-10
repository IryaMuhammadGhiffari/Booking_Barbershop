import 'package:flutter/material.dart';

// Palet warna utama: Hitam, Putih, Emas (barbershop style)
class AppColors {
  static const Color background   = Color(0xFF121212); // background gelap
  static const Color surface      = Color(0xFF1E1E1E); // card / container
  static const Color surfaceLight = Color(0xFF2A2A2A); // container lebih terang
  static const Color primary      = Color(0xFF1A1A1A); // hitam pekat
  static const Color secondary    = Color(0xFFD4AF37); // emas / gold
  static const Color gold         = Color(0xFFC9A84C); // gold lebih gelap
  static const Color white        = Color(0xFFFFFFFF);
  static const Color lightGrey    = Color(0xFFB0B0B0);
  static const Color grey         = Color(0xFF6B6B6B);
  static const Color divider      = Color(0xFF2E2E2E);
  static const Color error        = Color(0xFFCF6679);
  static const Color success      = Color(0xFF4CAF50);
  static const Color warning      = Color(0xFFFFC107);

  // Gradient emas
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E07C), Color(0xFFC9A84C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient gelap
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
