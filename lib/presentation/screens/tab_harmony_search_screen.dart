import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/harmonic_mode_visuals.dart';
import '../../domain/models/harmonic_key_model.dart';
import '../providers/harmony_search_provider.dart';
import '../widgets/cuatro_fretboard_widget.dart';
import '../widgets/degree_selector_bar.dart';
import '../widgets/glass_card.dart';

class TabHarmonySearchScreen extends StatelessWidget {
  final HarmonySearchProvider provider;

  const TabHarmonySearchScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final selectedKey = provider.selectedKey;
    final chord = provider.currentChord;
    final currentDegreeObj = selectedKey?.getDegree(provider.selectedDegree);

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
            // Header Dropdown: Key Selection
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.selectKey,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<HarmonicKeyModel>(
                      value: selectedKey,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundCard,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryAmber),
                      items: provider.allKeys.map((key) {
                        return DropdownMenuItem<HarmonicKeyModel>(
                          value: key,
                          child: Row(
                            children: [
                              Icon(
                                HarmonicModeVisuals.iconFor(key.mode),
                                color: HarmonicModeVisuals.colorFor(key.mode),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                key.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newKey) {
                        if (newKey != null) provider.selectKey(newKey);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Degree Selector Bar (I to VII)
            DegreeSelectorBar(
              selectedDegree: provider.selectedDegree,
              onDegreeSelected: provider.selectDegree,
            ),
            const SizedBox(height: 16),

            // Chord Display Card
            if (chord != null) ...[
              GlassCard(
                borderColor: AppColors.primaryAmber,
                child: Column(
                  children: [
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
                              if (currentDegreeObj != null)
                                Text(
                                  'Grado ${currentDegreeObj.degree} • ${currentDegreeObj.role}',
                                  style: const TextStyle(
                                    color: AppColors.accentCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: provider.playCurrentChord,
                        icon: const Icon(Icons.volume_up, color: Colors.white, size: 18),
                          label: const Text('Escuchar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryCopper,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Fretboard Visualizer
              CuatroFretboardWidget(
                frets: chord.frets,
                isInteractive: false,
                onFretTapped: (stringIndex, fret) {
                  provider.playSingleNote(stringIndex, fret);
                },
              ),
            ] else ...[
              const GlassCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No se encontró acorde para la combinación seleccionada.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
