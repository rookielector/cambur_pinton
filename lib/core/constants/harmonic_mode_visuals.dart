import 'package:flutter/material.dart';
import 'app_colors.dart';

class HarmonicModeVisuals {
  static IconData iconFor(String mode) {
    switch (mode) {
      case 'major':
        return Icons.wb_sunny;
      case 'minor':
        return Icons.nightlight_round;
      case 'harmonic_minor':
        return Icons.auto_awesome;
      case 'melodic_minor':
        return Icons.multitrack_audio;
      case 'dorian':
        return Icons.water_drop;
      case 'mixolydian':
        return Icons.wb_twilight;
      default:
        return Icons.music_note;
    }
  }

  static Color colorFor(String mode) {
    switch (mode) {
      case 'major':
        return AppColors.primaryAmber;
      case 'minor':
        return AppColors.secondaryCopper;
      case 'harmonic_minor':
        return AppColors.modeHarmonicMinor;
      case 'melodic_minor':
        return AppColors.modeMelodicMinor;
      case 'dorian':
        return AppColors.modeDorian;
      case 'mixolydian':
        return AppColors.modeMixolydian;
      default:
        return AppColors.textSecondary;
    }
  }

  static String labelFor(String mode) {
    switch (mode) {
      case 'major':
        return 'Mayor';
      case 'minor':
        return 'Menor';
      case 'harmonic_minor':
        return 'Menor armónica';
      case 'melodic_minor':
        return 'Menor melódica';
      case 'dorian':
        return 'Dórico';
      case 'mixolydian':
        return 'Mixolidio';
      default:
        return mode;
    }
  }
}
