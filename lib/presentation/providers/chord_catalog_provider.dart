import 'package:flutter/foundation.dart';
import '../../core/services/cuatro_audio_service.dart';
import '../../domain/models/chord_model.dart';
import '../../domain/repositories/harmony_repository.dart';

enum ChordSortOption { notation, name }

class ChordCatalogProvider extends ChangeNotifier {
  final HarmonyRepository _repository;
  final CuatroAudioService _audioService = CuatroAudioService();

  List<ChordModel> _allChords = [];
  List<ChordModel> _filteredChords = [];
  ChordModel? _selectedChord;
  String _searchQuery = '';
  ChordSortOption _sortOption = ChordSortOption.notation;
  bool _sortAscending = true;

  ChordCatalogProvider(this._repository);

  List<ChordModel> get chords => List.unmodifiable(_filteredChords);
  ChordModel? get selectedChord => _selectedChord;
  String get searchQuery => _searchQuery;
  ChordSortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;
  int get totalChords => _allChords.length;

  void init() {
    _allChords = _repository.getAllChords();
    _applyFilters();
    if (_filteredChords.isNotEmpty) {
      _selectedChord = _filteredChords.first;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    setSearchQuery('');
  }

  void setSortOption(ChordSortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    _applyFilters();
    notifyListeners();
  }

  void selectChord(ChordModel chord) {
    _selectedChord = chord;
    notifyListeners();
  }

  void playSelectedChord() {
    final chord = _selectedChord;
    if (chord != null) {
      _audioService.playChord(chord.frets);
    }
  }

  void _applyFilters() {
    final normalizedQuery = _normalize(_searchQuery);
    _filteredChords = _allChords.where((chord) {
      if (normalizedQuery.isEmpty) return true;
      return _normalize(chord.notation).contains(normalizedQuery) ||
          _normalize(chord.nameEs).contains(normalizedQuery) ||
          _normalize(chord.displayTitle).contains(normalizedQuery);
    }).toList();

    _filteredChords.sort((first, second) {
      final firstValue = _sortOption == ChordSortOption.notation
          ? first.notation
          : first.nameEs;
      final secondValue = _sortOption == ChordSortOption.notation
          ? second.notation
          : second.nameEs;
      final comparison = _normalize(
        firstValue,
      ).compareTo(_normalize(secondValue));
      return _sortAscending ? comparison : -comparison;
    });

    if (_filteredChords.isEmpty) {
      _selectedChord = null;
    } else if (!_filteredChords.contains(_selectedChord)) {
      _selectedChord = _filteredChords.first;
    }
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }
}
