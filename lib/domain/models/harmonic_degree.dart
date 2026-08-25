class HarmonicDegree {
  final String degree; // I, II, III, IV, V, VI, VII
  final String chordId;
  final String role; // Tónica, Supertónica, Mediante, etc.

  const HarmonicDegree({
    required this.degree,
    required this.chordId,
    required this.role,
  });

  factory HarmonicDegree.fromJson(Map<String, dynamic> json) {
    return HarmonicDegree(
      degree: json['degree'] as String,
      chordId: json['chord_id'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'chord_id': chordId,
      'role': role,
    };
  }
}
