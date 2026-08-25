import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/chord_identifier_provider.dart';
import '../widgets/cuatro_fretboard_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/harmonic_roles_list.dart';

class TabChordIdentifierScreen extends StatelessWidget {
  final ChordIdentifierProvider provider;

  const TabChordIdentifierScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final chord = provider.identifiedChord;
    final roles = provider.harmonicRoles;

    final ScrollController scrollController = ScrollController();

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: Scrollbar(
        controller: scrollController,
        thickness: 6,
        radius: const Radius.circular(12),
        thumbVisibility: true,
        trackVisibility: false,
        interactive: true,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryAmber, width: 1.2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.music_note,
                          color: AppColors.primaryAmber,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        AppStrings.appSubtitle,
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          // Header & Clear Fretboard Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identificador de Pisadas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Toca los trastes para identificar el acorde',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: provider.resetFrets,
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.primaryAmber),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryAmber,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive Fretboard
          CuatroFretboardWidget(
            frets: provider.selectedFrets,
            isInteractive: true,
            onFretTapped: (stringIndex, fret) {
              provider.setFret(stringIndex, fret);
            },
          ),
          const SizedBox(height: 16),

          // Identification Result Card
          GlassCard(
            borderColor: chord != null ? AppColors.primaryAmber : AppColors.cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chord != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chord.displayTitle,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pisada: ${provider.selectedFrets.join(" - ")}',
                              style: const TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: provider.playIdentifiedChord,
                        icon: const Icon(Icons.volume_up, color: Colors.white, size: 18),
                        label: const Text('Escuchar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryCopper,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.accentGold, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.unknownChord,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Pisada actual: ${provider.selectedFrets.join(" - ")}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Harmonic Roles List
          HarmonicRolesList(roles: roles),
          ],
        ),
      ),
    );
  }
}
