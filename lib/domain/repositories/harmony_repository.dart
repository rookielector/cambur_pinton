import '../models/chord_model.dart';
import '../models/harmonic_key_model.dart';

abstract class HarmonyRepository {
  Future<void> initialize();
  List<ChordModel> getAllChords();
  List<HarmonicKeyModel> getKeys();
  List<HarmonicKeyModel> getMajorKeys();
  List<HarmonicKeyModel> getMinorKeys();
  ChordModel? getChordById(String chordId);
  ChordModel? getChordByFrets(List<int> frets);
  List<HarmonicRoleMatch> findHarmonicRolesForChord(List<int> frets);
}
