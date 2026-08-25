import 'package:flutter/foundation.dart';
import '../../core/services/cuatro_audio_service.dart';
import '../../domain/models/chord_model.dart';
import '../../domain/models/harmonic_key_model.dart';
import '../../domain/repositories/harmony_repository.dart';

class HarmonySearchProvider extends ChangeNotifier {
  final HarmonyRepository _repository;
  final CuatroAudioService _audioService = CuatroAudioService();

  List<HarmonicKeyModel> _allKeys = [];
  HarmonicKeyModel? _selectedKey;
  String _selectedDegree = 'I';
  ChordModel? _currentChord;

  HarmonySearchProvider(this._repository);

  List<HarmonicKeyModel> get allKeys => _allKeys;
  HarmonicKeyModel? get selectedKey => _selectedKey;
  String get selectedDegree => _selectedDegree;
  ChordModel? get currentChord => _currentChord;

  void init() {
    _allKeys = _repository.getKeys();
    if (_allKeys.isNotEmpty) {
      _selectedKey = _allKeys.first;
      _updateCurrentChord();
    }
  }

  void selectKey(HarmonicKeyModel key) {
    _selectedKey = key;
    _updateCurrentChord();
    notifyListeners();
  }

  void selectDegree(String degree) {
    _selectedDegree = degree;
    _updateCurrentChord();
    notifyListeners();
  }

  void _updateCurrentChord() {
    if (_selectedKey == null) {
      _currentChord = null;
      return;
    }
    final degreeObj = _selectedKey!.getDegree(_selectedDegree);
    if (degreeObj != null) {
      _currentChord = _repository.getChordById(degreeObj.chordId);
    } else {
      _currentChord = null;
    }
  }

  void playCurrentChord() {
    if (_currentChord != null) {
      _audioService.playChord(_currentChord!.frets);
    }
  }

  void playSingleNote(int stringIndex, int fret) {
    _audioService.playNote(stringIndex: stringIndex, fret: fret);
  }
}
