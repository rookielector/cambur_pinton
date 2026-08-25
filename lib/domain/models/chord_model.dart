class ChordModel {
  final String id;
  final String nameEs;
  final String notation;
  final String displayTitle;
  final List<int> frets; // [String 4, String 3, String 2, String 1]
  final int? barreFret;

  const ChordModel({
    required this.id,
    required this.nameEs,
    required this.notation,
    required this.displayTitle,
    required this.frets,
    this.barreFret,
  });

  factory ChordModel.fromJson(Map<String, dynamic> json) {
    return ChordModel(
      id: json['id'] as String,
      nameEs: json['name_es'] as String,
      notation: json['notation'] as String,
      displayTitle: json['display_title'] as String,
      frets: List<int>.from(json['frets'] as List),
      barreFret: json['barre_fret'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_es': nameEs,
      'notation': notation,
      'display_title': displayTitle,
      'frets': frets,
      'barre_fret': barreFret,
    };
  }

  String get fretsKey => frets.join(',');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChordModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
