import 'dart:math';

class CuatroTuner {

  static const List<double> baseFrequencies = [
    220.0,   // String 4: A3 (La3)
    293.66,  // String 3: D4 (Re4)
    369.99,  // String 2: F#4 (Fa#4)
    246.94,  // String 1: B3 (Si3 - re-entrante)
  ];


  static const List<String> chromaticNotes = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static const List<String> chromaticNotesEs = [
    'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si'
  ];


  static double getFrequency(int stringIndex, int fret) {
    if (stringIndex < 0 || stringIndex >= baseFrequencies.length) return 440.0;
    final baseFreq = baseFrequencies[stringIndex];
    return baseFreq * pow(2.0, fret / 12.0);
  }


  static String getNoteName(int stringIndex, int fret) {
    final List<int> openNoteIndices = [9, 2, 6, 11]; // A, D, F#, B
    if (stringIndex < 0 || stringIndex >= openNoteIndices.length) return '';
    final index = (openNoteIndices[stringIndex] + fret) % 12;
    return chromaticNotes[index];
  }


  static String getNoteNameEs(int stringIndex, int fret) {
    final List<int> openNoteIndices = [9, 2, 6, 11]; // La, Re, Fa#, Si
    if (stringIndex < 0 || stringIndex >= openNoteIndices.length) return '';
    final index = (openNoteIndices[stringIndex] + fret) % 12;
    return chromaticNotesEs[index];
  }

  static double getCentsOffset(double currentFreq, double targetFreq) {
    if (currentFreq <= 0 || targetFreq <= 0) return 0.0;
    return 1200.0 * (log(currentFreq / targetFreq) / log(2.0));
  }

  static String getTuningStatus(double cents) {
    if (cents.abs() <= 4.0) {
      return '¡Afinado!';
    } else if (cents < 0) {
      return 'Demasiado grave (Tensionar)';
    } else {
      return 'Demasiado agudo (Aflojar)';
    }
  }

  static final List<CuatroStringInfo> stringDetails = [
    const CuatroStringInfo(
      stringIndex: 0,
      label: '4ª Cuerda',
      noteEs: 'La3',
      noteEn: 'A3',
      frequency: 220.00,
      description: 'Cuerda superior. Nota La3 (220.00 Hz).',
    ),
    const CuatroStringInfo(
      stringIndex: 1,
      label: '3ª Cuerda',
      noteEs: 'Re4',
      noteEn: 'D4',
      frequency: 293.66,
      description: 'Cuerda intermedia superior.',
    ),
    const CuatroStringInfo(
      stringIndex: 2,
      label: '2ª Cuerda',
      noteEs: 'Fa#4',
      noteEn: 'F#4',
      frequency: 369.99,
      description: 'Cuerda intermedia inferior.',
    ),
    const CuatroStringInfo(
      stringIndex: 3,
      label: '1ª Cuerda',
      noteEs: 'Si3',
      noteEn: 'B3',
      frequency: 246.94,
      description: 'Cuerda inferior. Característica reentrante del Cuatro (más grave).',
    ),
  ];
}

class CuatroStringInfo {
  final int stringIndex;
  final String label;
  final String noteEs;
  final String noteEn;
  final double frequency;
  final String description;

  const CuatroStringInfo({
    required this.stringIndex,
    required this.label,
    required this.noteEs,
    required this.noteEn,
    required this.frequency,
    required this.description,
  });
}

