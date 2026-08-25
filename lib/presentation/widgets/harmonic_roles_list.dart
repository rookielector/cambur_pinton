import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/harmonic_key_model.dart';
import 'glass_card.dart';

class HarmonicRolesList extends StatelessWidget {
  final List<HarmonicRoleMatch> roles;

  const HarmonicRolesList({
    super.key,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const GlassCard(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              'No se encontraron funciones armónicas para esta pisada.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.music_note, color: AppColors.primaryAmber, size: 18),
            const SizedBox(width: 6),
            Text(
              'Funciones Armónicas (${roles.length} Tonalidades)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final match = roles[index];
            final isMajor = match.key.mode == 'major';

            return GlassCard(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isMajor
                          ? AppColors.primaryAmber.withValues(alpha: 0.2)
                          : AppColors.secondaryCopper.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isMajor
                            ? AppColors.primaryAmber
                            : AppColors.secondaryCopper,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        match.degree.degree,
                        style: TextStyle(
                          color: isMajor
                              ? AppColors.primaryAmber
                              : AppColors.secondaryCopper,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.key.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Grado ${match.degree.degree} • ${match.degree.role}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      isMajor ? 'Mayor' : 'Menor',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: isMajor
                        ? AppColors.primaryAmber.withValues(alpha: 0.4)
                        : AppColors.secondaryCopper.withValues(alpha: 0.4),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
