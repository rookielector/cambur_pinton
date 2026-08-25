import 'harmonic_degree.dart';

class HarmonicKeyModel {
  final String id;
  final String name; // e.g. "Do Mayor", "La Menor"
  final String mode; // "major" or "minor"
  final List<HarmonicDegree> degrees;

  const HarmonicKeyModel({
    required this.id,
    required this.name,
    required this.mode,
    required this.degrees,
  });

  factory HarmonicKeyModel.fromJson(Map<String, dynamic> json) {
    return HarmonicKeyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: json['mode'] as String,
      degrees: (json['degrees'] as List)
          .map((d) => HarmonicDegree.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode,
      'degrees': degrees.map((d) => d.toJson()).toList(),
    };
  }

  HarmonicDegree? getDegree(String degreeName) {
    try {
      return degrees.firstWhere((d) => d.degree == degreeName);
    } catch (_) {
      return null;
    }
  }
}

class HarmonicRoleMatch {
  final HarmonicKeyModel key;
  final HarmonicDegree degree;
  final String chordDisplayTitle;

  const HarmonicRoleMatch({
    required this.key,
    required this.degree,
    required this.chordDisplayTitle,
  });
}
