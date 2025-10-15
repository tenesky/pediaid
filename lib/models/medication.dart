class Medication {
  final String id;
  final String name;
  final String indication;
  final double dosePerKg;
  final String unit;
  final double? maxDose;
  final String route;
  final String concentration;
  final String source;
  final String? warning;
  final String colorBand;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.indication,
    required this.dosePerKg,
    required this.unit,
    this.maxDose,
    required this.route,
    required this.concentration,
    required this.source,
    this.warning,
    required this.colorBand,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'indication': indication,
    'dosePerKg': dosePerKg,
    'unit': unit,
    'maxDose': maxDose,
    'route': route,
    'concentration': concentration,
    'source': source,
    'warning': warning,
    'colorBand': colorBand,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'] as String,
    name: json['name'] as String,
    indication: json['indication'] as String,
    dosePerKg: (json['dosePerKg'] as num).toDouble(),
    unit: json['unit'] as String,
    maxDose: json['maxDose'] != null ? (json['maxDose'] as num).toDouble() : null,
    route: json['route'] as String,
    concentration: json['concentration'] as String,
    source: json['source'] as String,
    warning: json['warning'] as String?,
    colorBand: json['colorBand'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Medication copyWith({
    String? id,
    String? name,
    String? indication,
    double? dosePerKg,
    String? unit,
    double? maxDose,
    String? route,
    String? concentration,
    String? source,
    String? warning,
    String? colorBand,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    indication: indication ?? this.indication,
    dosePerKg: dosePerKg ?? this.dosePerKg,
    unit: unit ?? this.unit,
    maxDose: maxDose ?? this.maxDose,
    route: route ?? this.route,
    concentration: concentration ?? this.concentration,
    source: source ?? this.source,
    warning: warning ?? this.warning,
    colorBand: colorBand ?? this.colorBand,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  double calculateDose(double weightKg) {
    final calculatedDose = dosePerKg * weightKg;
    if (maxDose != null && calculatedDose > maxDose!) {
      return maxDose!;
    }
    return calculatedDose;
  }
}
