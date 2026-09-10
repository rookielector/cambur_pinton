import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cuatro_tuner.dart';

class CuatroFretboardWidget extends StatelessWidget {
  final List<int> frets; // [String 4 (La), String 3 (Re), String 2 (Fa#), String 1 (Si)]
  final bool isInteractive;
  final Function(int stringIndex, int fret)? onFretTapped;
  final int maxFrets;

  const CuatroFretboardWidget({
    super.key,
    required this.frets,
    this.isInteractive = false,
    this.onFretTapped,
    this.maxFrets = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.fretboardWood, AppColors.fretboardWoodDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.6), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Header: String Names (4ª La, 3ª Re, 2ª Fa#, 1ª Si)
          Row(
            children: [
              const SizedBox(width: 40), // Fret label margin
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (stringIndex) {
                    final names = ['4ª (La)', '3ª (Re)', '2ª (Fa#)', '1ª (Si)'];
                    return Text(
                      names[stringIndex],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nut (Cejuela de hueso)
          Row(
            children: [
              const SizedBox(
                width: 40,
                child: Text(
                  'Aire',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Vertical Fret Rows (Trastes 1 a maxFrets)
          ...List.generate(maxFrets, (fretIdx) {
            final fretNumber = fretIdx + 1;
            return _buildFretRow(context, fretNumber);
          }),
        ],
      ),
    );
  }

  Widget _buildFretRow(BuildContext context, int fretNumber) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          // Fret Number Label on the left margin
          SizedBox(
            width: 40,
            child: Text(
              'T.$fretNumber',
              style: TextStyle(
                color: _isFretActiveInAnyString(fretNumber)
                    ? AppColors.primaryAmber
                    : AppColors.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          // 4 String columns grid
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.fretWire, width: 1.5),
                ),
              ),
              child: Stack(
                children: [
                  // Fret Position Marker Dot (Incrustación en trastes 3 y 5)
                  if (fretNumber == 3 || fretNumber == 5)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.fretMarker.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                  // Barre Arch / Cejilla indicator if adjacent strings are pressed at same fret
                  _buildBarreArchIfPresent(fretNumber),

                  // 4 Vertical String Lines & Touch Areas
                  Row(
                    children: List.generate(4, (stringIndex) {
                      final activeFret = frets.length > stringIndex ? frets[stringIndex] : 0;
                      final isPressed = activeFret == fretNumber;
                      final stringThickness = [3.5, 2.8, 2.2, 1.8][stringIndex];

                      return Expanded(
                        child: GestureDetector(
                          onTap: isInteractive
                              ? () => onFretTapped?.call(stringIndex, fretNumber)
                              : null,
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Vertical Metallic String Line
                              Container(
                                width: stringThickness,
                                color: isPressed
                                    ? AppColors.stringHighlight
                                    : AppColors.stringColor.withValues(alpha: 0.7),
                              ),

                              // Finger Position Marker Dot
                              if (isPressed)
                                _buildFingerMarker(stringIndex, fretNumber),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isFretActiveInAnyString(int fretNumber) {
    return frets.contains(fretNumber);
  }

  Widget _buildBarreArchIfPresent(int fretNumber) {
    int firstActiveStr = -1;
    int lastActiveStr = -1;

    for (int s = 0; s < frets.length && s < 4; s++) {
      if (frets[s] == fretNumber) {
        if (firstActiveStr == -1) firstActiveStr = s;
        lastActiveStr = s;
      }
    }

    if (firstActiveStr != -1 && lastActiveStr > firstActiveStr) {
      return Positioned(
        top: 2,
        left: (firstActiveStr * 60.0) + 18,
        right: ((3 - lastActiveStr) * 60.0) + 18,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accentCyan.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFingerMarker(int stringIndex, int fret) {
    final noteName = CuatroTuner.getNoteNameEs(stringIndex, fret);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAmber.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          noteName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
