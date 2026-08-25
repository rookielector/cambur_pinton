import 'package:flutter/material.dart';

class AppColors {

  static const Color backgroundDark = Color(0xFF140D09);
  static const Color backgroundCard = Color(0xFF221610);
  static const Color backgroundGlass = Color(0x28FFFFFF);
  static const Color cardBorder = Color(0x33FFB74D);


  static const Color primaryAmber = Color(0xFFFF9800);
  static const Color secondaryCopper = Color(0xFFE65100);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentGold = Color(0xFFFFD54F);


  static const Color textPrimary = Color(0xFFFFF8E1);
  static const Color textSecondary = Color(0xFFBCAAA4);
  static const Color textMuted = Color(0xFF8D6E63);


  static const Color fretboardWood = Color(0xFF2A1C14);
  static const Color fretboardWoodDark = Color(0xFF1C120C);
  static const Color fretWire = Color(0xFFB0BEC5);
  static const Color stringColor = Color(0xFFFFE0B2);
  static const Color stringHighlight = Color(0xFF00E5FF);
  static const Color fretMarker = Color(0xFFFFCC80);


  static const LinearGradient primaryGradient = LinearGradient(
    colors: [secondaryCopper, primaryAmber],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A110C), Color(0xFF0D0805)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
