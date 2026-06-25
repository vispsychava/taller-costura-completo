// lib/models/measurements.dart
class Measurements {
  final double bust;
  final double waist;
  final double hip;
  final double shoulder;
  final double sleeve;
  final double length;
  final String notes;

  Measurements({
    this.bust = 0,
    this.waist = 0,
    this.hip = 0,
    this.shoulder = 0,
    this.sleeve = 0,
    this.length = 0,
    this.notes = '',
  });

  static Measurements empty() {
    return Measurements();
  }

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      bust: json['bust']?.toDouble() ?? 0,
      waist: json['waist']?.toDouble() ?? 0,
      hip: json['hip']?.toDouble() ?? 0,
      shoulder: json['shoulder']?.toDouble() ?? 0,
      sleeve: json['sleeve']?.toDouble() ?? 0,
      length: json['length']?.toDouble() ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bust': bust,
      'waist': waist,
      'hip': hip,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'length': length,
      'notes': notes,
    };
  }
}