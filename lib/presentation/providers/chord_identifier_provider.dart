import 'package:flutter/foundation.dart';
import '../../core/services/cuatro_audio_service.dart';
import '../../domain/models/chord_model.dart';
import '../../domain/models/harmonic_key_model.dart';
import '../../domain/repositories/harmony_repository.dart';

class ChordIdentifierProvider extends ChangeNotifier {
  final HarmonyRepository _repository;
  final CuatroAudioService _audioService = CuatroAudioService();

  List<int> _selectedFrets = [0, 0, 0, 0];
  ChordModel? _identifiedChord;
  List<HarmonicRoleMatch> _harmonicRoles = [];

  ChordIdentifierProvider(this._repository);

  List<int> get selectedFrets => List.unmodifiable(_selectedFrets);
  ChordModel? get identifiedChord => _identifiedChord;
  List<HarmonicRoleMatch> get harmonicRoles => _harmonicRoles;

  void setFret(int stringIndex, int fret) {
    if (stringIndex < 0 || stringIndex >= 4) return;
    if (_selectedFrets[stringIndex] == fret) {
      _selectedFrets[stringIndex] = 0; // Unselect back to open string
    } else {
      _selectedFrets[stringIndex] = fret;
    }
    
    _audioService.playNote(stringIndex: stringIndex, fret: _selectedFrets[stringIndex]);
    _evaluateFingerPosition();
    notifyListeners();
  }

  void resetFrets() {
    _selectedFrets = [0, 0, 0, 0];
    _evaluateFingerPosition();
    notifyListeners();
  }

  void _evaluateFingerPosition() {
    _identifiedChord = _repository.getChordByFrets(_selectedFrets);
    _harmonicRoles = _repository.findHarmonicRolesForChord(_selectedFrets);
  }

  void playIdentifiedChord() {
    _audioService.playChord(_selectedFrets);
  }
}
