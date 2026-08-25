import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../utils/cuatro_tuner.dart';

class CuatroAudioService {
  static final CuatroAudioService _instance = CuatroAudioService._internal();
  factory CuatroAudioService() => _instance;
  CuatroAudioService._internal();

  final List<AudioPlayer> _players = List.generate(4, (_) => AudioPlayer());
  int _currentPlayerIndex = 0;

  AudioPlayer _getFreePlayer() {
    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    return player;
  }


  Future<void> playNote({required int stringIndex, required int fret}) async {
    try {
      final double freq = CuatroTuner.getFrequency(stringIndex, fret);
      final Uint8List wavBytes = _generatePluckWav(freq, durationSeconds: 1.2);
      final player = _getFreePlayer();
      await player.play(BytesSource(wavBytes));
    } catch (e) {
      // Ignore background audio play exceptions gracefully
    }
  }


  Future<void> playChord(List<int> frets) async {
    if (frets.length != 4) return;
    for (int stringIndex = 0; stringIndex < 4; stringIndex++) {
      final fret = frets[stringIndex];
      playNote(stringIndex: stringIndex, fret: fret);
      await Future.delayed(const Duration(milliseconds: 45));
    }
  }


  Uint8List _generatePluckWav(double frequency, {double durationSeconds = 1.0}) {
    const int sampleRate = 22050; // Moderate sample rate for speed and memory efficiency
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final int dataSize = numSamples * 2; // 16-bit PCM = 2 bytes per sample
    final int fileSize = 36 + dataSize;

    final Uint8List buffer = Uint8List(44 + dataSize);
    final ByteData bd = ByteData.sublistView(buffer);

    // RIFF Header
    bd.setUint8(0, 0x52); // 'R'
    bd.setUint8(1, 0x49); // 'I'
    bd.setUint8(2, 0x46); // 'F'
    bd.setUint8(3, 0x46); // 'F'
    bd.setUint32(4, fileSize, Endian.little);
    bd.setUint8(8, 0x57);  // 'W'
    bd.setUint8(9, 0x41);  // 'A'
    bd.setUint8(10, 0x56); // 'V'
    bd.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    bd.setUint8(12, 0x66); // 'f'
    bd.setUint8(13, 0x6D); // 'm'
    bd.setUint8(14, 0x74); // 't'
    bd.setUint8(15, 0x20); // ' '
    bd.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    bd.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    bd.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    bd.setUint16(32, 2, Endian.little); // BlockAlign
    bd.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    bd.setUint8(36, 0x64); // 'd'
    bd.setUint8(37, 0x61); // 'a'
    bd.setUint8(38, 0x74); // 't'
    bd.setUint8(39, 0x61); // 'a'
    bd.setUint32(40, dataSize, Endian.little);

    // Audio Synthesis: Plucked String Simulation (Harmonics + Exponential Decay)
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double decay = exp(-4.0 * t);
      
      // Harmonic series for Cuatro nylon/gut sound
      double sampleValue = 0.0;
      sampleValue += 0.60 * sin(2 * pi * frequency * t);
      sampleValue += 0.25 * sin(2 * pi * frequency * 2 * t);
      sampleValue += 0.10 * sin(2 * pi * frequency * 3 * t);
      sampleValue += 0.05 * sin(2 * pi * frequency * 4 * t);

      // Micro attack transient
      if (t < 0.005) {
        sampleValue *= (t / 0.005);
      }

      final double amplitude = sampleValue * decay;
      final int pcmValue = (amplitude * 28000).clamp(-32767.0, 32767.0).toInt();

      bd.setInt16(44 + (i * 2), pcmValue, Endian.little);
    }

    return buffer;
  }

  void dispose() {
    for (final player in _players) {
      player.dispose();
    }
  }
}
