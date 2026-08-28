import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cuatro_tuner.dart';

class CuatroTunerGraphicWidget extends StatelessWidget {
  final int selectedStringIndex;
  final ValueChanged<int> onStringSelected;
  final VoidCallback? onPlaySound;

  const CuatroTunerGraphicWidget({
    super.key,
    required this.selectedStringIndex,
    required this.onStringSelected,
    this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.fretboardWoodDark, AppColors.fretboardWood],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryAmber.withValues(alpha: 0.5),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.primaryAmber,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Seleccionar Cuerda a Afinar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (onPlaySound != null)
                IconButton(
                  onPressed: onPlaySound,
                  tooltip: 'Escuchar nota de referencia',
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.accentGold,
                    size: 22,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal/Vertical String Buttons Grid
          Row(
            children: List.generate(4, (index) {
              final stringInfo = CuatroTuner.stringDetails[index];
              final isSelected = (index == selectedStringIndex);
              final stringThickness = [3.5, 2.8, 2.2, 1.8][index];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => onStringSelected(index),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryAmber.withValues(alpha: 0.15)
                            : AppColors.backgroundDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAmber
                              : AppColors.cardBorder.withValues(alpha: 0.4),
                          width: isSelected ? 2.2 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryAmber.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // String Note Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.primaryGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : AppColors.fretboardWood,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              stringInfo.noteEs,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Visual String Line Representation
                          SizedBox(
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Fretboard wood background behind string
                                Container(
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.fretboardWoodDark,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.fretWire.withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                ),

                                // Metallic String
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? stringThickness + 1.5 : stringThickness,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.stringHighlight
                                        : AppColors.stringColor.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.stringHighlight.withValues(alpha: 0.8),
                                              blurRadius: 6,
                                            )
                                          ]
                                        : [],
                                  ),
                                ),

                                // Peg / Clavija indicator icon
                                Positioned(
                                  top: 0,
                                  child: Icon(
                                    Icons.adjust,
                                    size: 14,
                                    color: isSelected
                                        ? AppColors.accentGold
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // String Label (4ª, 3ª, 2ª, 1ª)
                          Text(
                            stringInfo.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryAmber
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          // Frequency Hz
                          Text(
                            '${stringInfo.frequency.toStringAsFixed(1)} Hz',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
