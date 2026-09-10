import 'package:flutter_test/flutter_test.dart';
import 'package:cambur_pinton/data/repositories/harmony_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HarmonyRepositoryImpl loads 300 chords and 72 harmonies', () async {
    final repo = HarmonyRepositoryImpl();
    await repo.initialize();

    final chords = repo.getAllChords();
    expect(chords.length, 300);

    final keys = repo.getKeys();
    expect(keys.length, 72);

    final majorKeys = repo.getMajorKeys();
    expect(majorKeys.length, 12);

    final minorKeys = repo.getMinorKeys();
    expect(minorKeys.length, 12);
  });

  test('returns every chord that shares the same fret position', () async {
    final repo = HarmonyRepositoryImpl();
    await repo.initialize();

    final matches = repo.getChordsByFrets([2, 3, 1, 4]);

    expect(matches.length, 19);
    expect(matches.map((chord) => chord.id), contains('e_m7'));
    expect(matches.map((chord) => chord.id), contains('a_sharp_9'));
  });
}
