import 'dart:math' show sqrt;

class PatientData {
  final double? ageYears;
  final double? weightKg;
  final double? heightCm;
  final double? bodySurfaceArea;

  PatientData({
    this.ageYears,
    this.weightKg,
    this.heightCm,
    this.bodySurfaceArea,
  });

  Map<String, dynamic> toJson() => {
    'ageYears': ageYears,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bodySurfaceArea': bodySurfaceArea,
  };

  factory PatientData.fromJson(Map<String, dynamic> json) => PatientData(
    ageYears: json['ageYears'] as double?,
    weightKg: json['weightKg'] as double?,
    heightCm: json['heightCm'] as double?,
    bodySurfaceArea: json['bodySurfaceArea'] as double?,
  );

  PatientData copyWith({
    double? ageYears,
    double? weightKg,
    double? heightCm,
    double? bodySurfaceArea,
  }) => PatientData(
    ageYears: ageYears ?? this.ageYears,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    bodySurfaceArea: bodySurfaceArea ?? this.bodySurfaceArea,
  );

  double calculateBSA() {
    if (weightKg != null && heightCm != null) {
      // Mosteller formula: sqrt((height(cm) * weight(kg)) / 3600)
      final v = (heightCm! * weightKg!) / 3600.0;
      if (v <= 0) return 0.0;
      return sqrt(v);
    }
    return 0.0;
  }
}
