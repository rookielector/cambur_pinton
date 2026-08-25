import 'dart:math';

class CuatroTuner {

  static const List<double> baseFrequencies = [
    440.0,   // String 4: A4 (La)
    293.66,  // String 3: D4 (Re)
    369.99,  // String 2: F#4 (Fa#)
    246.94,  // String 1: B3 (Si - re-entrante)
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
}
