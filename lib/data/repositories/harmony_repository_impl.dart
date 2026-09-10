import 'dart:convert';
import '../../core/services/asset_loader_service.dart';
import '../../domain/models/chord_model.dart';
import '../../domain/models/harmonic_key_model.dart';
import '../../domain/repositories/harmony_repository.dart';

class HarmonyRepositoryImpl implements HarmonyRepository {
  final Map<String, ChordModel> _chordsById = {};
  final Map<String, List<ChordModel>> _chordsByFrets = {};
  final List<HarmonicKeyModel> _keys = [];
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    final chordsRaw = await AssetLoaderService.loadJsonString(
      'assets/data/chords.json',
    );
    final List<dynamic> chordsJson = jsonDecode(chordsRaw);

    for (final item in chordsJson) {
      final chord = ChordModel.fromJson(item as Map<String, dynamic>);
      _chordsById[chord.id] = chord;
      _chordsByFrets.putIfAbsent(chord.fretsKey, () => []).add(chord);
    }

    final harmoniesRaw = await AssetLoaderService.loadJsonString(
      'assets/data/harmonies.json',
    );
    final List<dynamic> harmoniesJson = jsonDecode(harmoniesRaw);

    for (final item in harmoniesJson) {
      final keyModel = HarmonicKeyModel.fromJson(item as Map<String, dynamic>);
      _keys.add(keyModel);
    }

    _isInitialized = true;
  }

  @override
  List<ChordModel> getAllChords() => List.unmodifiable(_chordsById.values);

  @override
  List<HarmonicKeyModel> getKeys() => List.unmodifiable(_keys);

  @override
  List<HarmonicKeyModel> getMajorKeys() =>
      _keys.where((k) => k.mode == 'major').toList();

  @override
  List<HarmonicKeyModel> getMinorKeys() =>
      _keys.where((k) => k.mode == 'minor').toList();

  @override
  ChordModel? getChordById(String chordId) => _chordsById[chordId];

  @override
  List<ChordModel> getChordsByFrets(List<int> frets) {
    final key = frets.join(',');
    return List.unmodifiable(_chordsByFrets[key] ?? const []);
  }

  @override
  List<HarmonicRoleMatch> findHarmonicRolesForChord(String chordId) {
    final targetChord = getChordById(chordId);
    if (targetChord == null) return [];

    final List<HarmonicRoleMatch> matches = [];

    for (final key in _keys) {
      for (final deg in key.degrees) {
        if (deg.chordId == targetChord.id) {
          matches.add(
            HarmonicRoleMatch(
              key: key,
              degree: deg,
              chordDisplayTitle: targetChord.displayTitle,
            ),
          );
        }
      }
    }

    return matches;
  }
}
