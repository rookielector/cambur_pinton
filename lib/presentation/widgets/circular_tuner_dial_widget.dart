import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CircularTunerDialWidget extends StatefulWidget {
  final String targetNote;
  final String stringLabel;
  final double targetFreq;
  final double currentFreq;
  final double cents;
  final bool isListening;
  final String? customStatus;

  const CircularTunerDialWidget({
    super.key,
    required this.targetNote,
    required this.stringLabel,
    required this.targetFreq,
    required this.currentFreq,
    required this.cents,
    this.isListening = false,
    this.customStatus,
  });

  @override
  State<CircularTunerDialWidget> createState() => _CircularTunerDialWidgetState();
}

class _CircularTunerDialWidgetState extends State<CircularTunerDialWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _centsAnimation;
  double _oldCents = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _centsAnimation = Tween<double>(
      begin: widget.cents,
      end: widget.cents,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant CircularTunerDialWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cents != widget.cents) {
      _oldCents = _centsAnimation.value;
      _centsAnimation = Tween<double>(
        begin: _oldCents,
        end: widget.cents.clamp(-50.0, 50.0),
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ));
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getStatusColor(double cents) {
    final absCents = cents.abs();
    if (absCents <= 4.0) {
      return const Color(0xFF00E676); // Vibrant Green - In tune
    } else if (absCents <= 18.0) {
      return AppColors.accentGold; // Amber/Gold - Close
    } else {
      return const Color(0xFFFF5252); // Red/Coral - Out of tune
    }
  }

  String _getStatusMessage(double cents) {
    if (widget.customStatus != null && widget.customStatus!.isNotEmpty) {
      return widget.customStatus!;
    }
    final absCents = cents.abs();
    if (absCents <= 4.0) {
      return '¡AFINADO!';
    } else if (cents < 0) {
      return 'Bajo (Tensionar ▲)';
    } else {
      return 'Alto (Aflojar ▼)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _centsAnimation,
      builder: (context, child) {
        final currentCents = _centsAnimation.value;
        final statusColor = _getStatusColor(currentCents);
        final statusText = _getStatusMessage(currentCents);

        return Container(
          width: 270,
          height: 270,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                AppColors.backgroundCard,
                AppColors.backgroundDark,
              ],
              center: Alignment.center,
              radius: 0.85,
            ),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.4),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painter for Arc & Ticks & Needle
              CustomPaint(
                size: const Size(260, 260),
                painter: _TunerGaugePainter(
                  cents: currentCents,
                  statusColor: statusColor,
                ),
              ),

              // Center Display Card
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 28),
                  // String Label (e.g. "4ª Cuerda")
                  Text(
                    widget.stringLabel.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Main Target Note (e.g. "La4")
                  Text(
                    widget.targetNote,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: statusColor.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),

                  // Frequency Hz Readout
                  Text(
                    '${widget.currentFreq.toStringAsFixed(1)} Hz / ${widget.targetFreq.toStringAsFixed(1)} Hz',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status Pill Badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    constraints: const BoxConstraints(maxWidth: 210),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentCents.abs() <= 4.0
                              ? Icons.check_circle
                              : (currentCents < 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward),
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            statusText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Cents deviation value
                  Text(
                    '${currentCents >= 0 ? "+" : ""}${currentCents.toStringAsFixed(0)} Cents',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TunerGaugePainter extends CustomPainter {
  final double cents; // -50 to +50
  final Color statusColor;

  _TunerGaugePainter({
    required this.cents,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Angle configuration: Sweep 260 degrees from 140 deg to 400 deg
    const startAngle = 140 * (pi / 180);
    const sweepAngle = 260 * (pi / 180);

    // 1. Draw Outer Track Arc
    final trackPaint = Paint()
      ..color = AppColors.fretboardWoodDark.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Center Green Zone (-5 to +5 cents)
    const zeroAngle = startAngle + (sweepAngle / 2);
    const greenWidth = (10 / 100) * sweepAngle; // 10 cents total range
    final greenPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      zeroAngle - (greenWidth / 2),
      greenWidth,
      false,
      greenPaint,
    );

    // 3. Draw Tick Marks (-50, -25, 0, +25, +50)
    final tickPaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 2.0;

    final majorTickPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 3.0;

    for (int c = -50; c <= 50; c += 10) {
      final normalized = (c + 50) / 100.0;
      final tickAngle = startAngle + (normalized * sweepAngle);
      final isMajor = (c % 25 == 0);
      final tickLength = isMajor ? 14.0 : 8.0;

      final p1 = Offset(
        center.dx + (radius - tickLength) * cos(tickAngle),
        center.dy + (radius - tickLength) * sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + radius * cos(tickAngle),
        center.dy + radius * sin(tickAngle),
      );

      final p = isMajor ? majorTickPaint : tickPaint;
      if (c == 0) {
        p.color = const Color(0xFF00E676);
      } else {
        p.color = isMajor ? AppColors.accentGold : AppColors.textMuted;
      }

      canvas.drawLine(p1, p2, p);
    }

    // 4. Draw Needle
    final clampedCents = cents.clamp(-50.0, 50.0);
    final needleNormalized = (clampedCents + 50.0) / 100.0;
    final needleAngle = startAngle + (needleNormalized * sweepAngle);

    final needleLength = radius - 24;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    // Needle shadow
    canvas.drawLine(
      center,
      needleEnd + const Offset(2, 2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );

    // Needle main line
    final needlePaint = Paint()
      ..color = statusColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center Pivot Circle
    final pivotPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7, pivotPaint);

    final pivotInner = Paint()
      ..color = AppColors.backgroundDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, pivotInner);
  }

  @override
  bool shouldRepaint(covariant _TunerGaugePainter oldDelegate) {
    return oldDelegate.cents != cents || oldDelegate.statusColor != statusColor;
  }
}
