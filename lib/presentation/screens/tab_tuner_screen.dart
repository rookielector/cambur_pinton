import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/cuatro_audio_service.dart';
import '../../core/services/pitch_detector_web_service.dart';
import '../../core/utils/cuatro_tuner.dart';
import '../widgets/circular_tuner_dial_widget.dart';
import '../widgets/cuatro_tuner_graphic_widget.dart';
import '../widgets/glass_card.dart';

enum TunerMode {
  microphone,
  referenceTone,
}

class TabTunerScreen extends StatefulWidget {
  const TabTunerScreen({super.key});

  @override
  State<TabTunerScreen> createState() => _TabTunerScreenState();
}

class _TabTunerScreenState extends State<TabTunerScreen> {
  final CuatroAudioService _audioService = CuatroAudioService();
  final PitchDetectorWebService _pitchDetector = PitchDetectorWebService();
  
  TunerMode _mode = TunerMode.referenceTone;
  int _selectedStringIndex = 0; // 0 = 4ª (La3 220Hz), 1 = 3ª (Re4), 2 = 2ª (Fa#4), 3 = 1ª (Si3)

  // Simulation & Real Pitch state variables
  double _currentCents = 0.0;
  double _currentFreqHz = 220.0;
  bool _isAutoSimulating = false;
  Timer? _simulationTimer;
  bool _isPlayingAudio = false;

  // Microphone stream subscriptions
  StreamSubscription<double>? _pitchSub;
  StreamSubscription<String>? _errSub;
  String? _micStatusMsg;

  @override
  void initState() {
    super.initState();
    _currentFreqHz = CuatroTuner.stringDetails[_selectedStringIndex].frequency;
  }

  @override
  void dispose() {
    _stopMicrophoneListening();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startMicrophoneListening() {
    _stopMicrophoneListening();
    if (_isAutoSimulating) {
      _toggleAutoSimulation();
    }

    setState(() {
      _micStatusMsg = 'Solicitando acceso al micrófono...';
    });

    _pitchDetector.start();

    _pitchSub = _pitchDetector.pitchStream?.listen((pitch) {
      if (!mounted || _mode != TunerMode.microphone) return;

      if (pitch <= 0) {
        setState(() {
          _micStatusMsg = '🎙️ Escuchando... Toca una cuerda de tu Cuatro';
        });
      } else {
        // Find closest Cuatro string automatically based on frequency
        int closestStringIndex = _selectedStringIndex;
        double minDistance = double.infinity;

        for (int i = 0; i < CuatroTuner.stringDetails.length; i++) {
          final target = CuatroTuner.stringDetails[i].frequency;
          final dist = (pitch - target).abs();
          if (dist < minDistance) {
            minDistance = dist;
            closestStringIndex = i;
          }
        }

        // Only switch string automatically if distance is reasonable (within 40 Hz)
        if (minDistance <= 45.0 && closestStringIndex != _selectedStringIndex) {
          _selectedStringIndex = closestStringIndex;
        }

        final targetFreq = CuatroTuner.stringDetails[_selectedStringIndex].frequency;
        final cents = CuatroTuner.getCentsOffset(pitch, targetFreq);

        setState(() {
          _currentFreqHz = pitch;
          _currentCents = cents;
          _micStatusMsg = null;
        });
      }
    });

    _errSub = _pitchDetector.errorStream?.listen((err) {
      if (!mounted) return;
      setState(() {
        _micStatusMsg = '⚠️ Ocurrió un error o se denegó el permiso del micrófono.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de micrófono: $err'),
          backgroundColor: Colors.redAccent,
        ),
      );
    });
  }

  void _stopMicrophoneListening() {
    _pitchSub?.cancel();
    _errSub?.cancel();
    _pitchSub = null;
    _errSub = null;
    _pitchDetector.stop();
  }

  void _playCurrentReferenceTone() {
    setState(() {
      _isPlayingAudio = true;
    });
    // Open string fret is 0
    _audioService.playNote(stringIndex: _selectedStringIndex, fret: 0);
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    });
  }

  void _playFullArpeggio() {
    _audioService.playChord(const [0, 0, 0, 0]);
  }

  void _toggleAutoSimulation() {
    if (_isAutoSimulating) {
      _simulationTimer?.cancel();
      setState(() {
        _isAutoSimulating = false;
        _currentCents = 0.0;
        _currentFreqHz = CuatroTuner.stringDetails[_selectedStringIndex].frequency;
      });
    } else {
      if (_mode == TunerMode.microphone) {
        _stopMicrophoneListening();
        _mode = TunerMode.referenceTone;
      }
      setState(() {
        _isAutoSimulating = true;
      });
      double dir = 1.0;
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (!mounted) return;
        final target = CuatroTuner.stringDetails[_selectedStringIndex].frequency;
        setState(() {
          _currentCents += (2.5 * dir);
          if (_currentCents >= 45.0) {
            dir = -1.0;
          } else if (_currentCents <= -45.0) {
            dir = 1.0;
          }
          _currentFreqHz = target * (1 + (_currentCents / 1200.0) * 0.5);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stringInfo = CuatroTuner.stringDetails[_selectedStringIndex];
    final targetFreq = stringInfo.frequency;

    if (!_isAutoSimulating && _mode == TunerMode.referenceTone) {
      _currentFreqHz = targetFreq;
      _currentCents = 0.0;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title Header
                  const Text(
                    AppStrings.tunerTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.tunerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mode Selector Tabs (Mic vs Reference)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeTab(
                          mode: TunerMode.referenceTone,
                          icon: Icons.volume_up_rounded,
                          label: 'Tonos de Referencia',
                        ),
                        _buildModeTab(
                          mode: TunerMode.microphone,
                          icon: Icons.mic_rounded,
                          label: 'Micrófono (En vivo)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Tuning Area (Circular Dial)
                  CircularTunerDialWidget(
                    targetNote: stringInfo.noteEs,
                    stringLabel: stringInfo.label,
                    targetFreq: targetFreq,
                    currentFreq: _currentFreqHz,
                    cents: _currentCents,
                    isListening: _mode == TunerMode.microphone,
                    customStatus: _isPlayingAudio
                        ? '▶ Sonando nota...'
                        : (_mode == TunerMode.microphone ? _micStatusMsg : null),
                  ),

                  const SizedBox(height: 20),

                  // Interactive Cuatro Strings Graphic
                  CuatroTunerGraphicWidget(
                    selectedStringIndex: _selectedStringIndex,
                    onStringSelected: (index) {
                      setState(() {
                        _selectedStringIndex = index;
                        _currentFreqHz = CuatroTuner.stringDetails[index].frequency;
                        _currentCents = 0.0;
                      });
                      if (_mode == TunerMode.referenceTone) {
                        _playCurrentReferenceTone();
                      }
                    },
                    onPlaySound: _playCurrentReferenceTone,
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons Bar
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _playCurrentReferenceTone,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Escuchar ${stringInfo.noteEs} (${stringInfo.label})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _playFullArpeggio,
                        icon: const Icon(Icons.music_note_rounded),
                        label: const Text('Rasgueo Cambur Pintón'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentGold,
                          side: const BorderSide(color: AppColors.accentGold),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _toggleAutoSimulation,
                        icon: Icon(
                          _isAutoSimulating ? Icons.pause_rounded : Icons.tune_rounded,
                        ),
                        label: Text(
                          _isAutoSimulating ? 'Detener Simulación' : 'Simular Aguja',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isAutoSimulating
                              ? AppColors.primaryAmber
                              : AppColors.textSecondary,
                          side: BorderSide(
                            color: _isAutoSimulating
                                ? AppColors.primaryAmber
                                : AppColors.cardBorder,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Educational Usage & Instructions Section
                  _buildEducationalSection(context),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required TunerMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = (_mode == mode);
    return InkWell(
      onTap: () {
        setState(() {
          _mode = mode;
          if (_mode == TunerMode.microphone) {
            _startMicrophoneListening();
          } else {
            _stopMicrophoneListening();
            _currentCents = 0.0;
            _currentFreqHz = CuatroTuner.stringDetails[_selectedStringIndex].frequency;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.black : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Instrucciones y Afinación Tradicional del Cuatro',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'El Cuatro Venezolano utiliza tradicionalmente la afinación reentrante conocida como "Cambur Pintón" (La3 - Re4 - Fa#4 - Si3). La 4ª cuerda es La3 (220.00 Hz), la 3ª cuerda es Re4 (293.66 Hz), la 2ª cuerda es Fa#4 (369.99 Hz) y la 1ª cuerda reentrante es Si3 (246.94 Hz).',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Table of Strings & Frequencies
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(CuatroTuner.stringDetails.length, (idx) {
                  final info = CuatroTuner.stringDetails[idx];
                  final isLast = (idx == CuatroTuner.stringDetails.length - 1);

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
                            ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryAmber,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${4 - idx}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                                '${info.label}: ${info.noteEs} (${info.noteEn})',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                info.description,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${info.frequency.toStringAsFixed(2)} Hz',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Tuning Tips List
            const Text(
              '💡 Consejos de Afinación:',
              style: TextStyle(
                color: AppColors.primaryAmber,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildTipRow('1. Tensa la cuerda siempre desde abajo (subiendo tono) para que la clavija mantenga la tensión firmemente.'),
            _buildTipRow('2. La 4ª cuerda (La3 - 220.00 Hz) es la base tonal más grave del Cuatro Venezolano.'),
            _buildTipRow('3. En el Modo Micrófono, toca la cuerda suavemente cerca de tu teléfono o computadora. En el Modo Referencia, escucha y afina de oído.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
