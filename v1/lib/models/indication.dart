class Indication {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorBand;
  final List<String> medicationIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Indication({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorBand,
    required this.medicationIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconName': iconName,
    'colorBand': colorBand,
    'medicationIds': medicationIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Indication.fromJson(Map<String, dynamic> json) => Indication(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    iconName: json['iconName'] as String,
    colorBand: json['colorBand'] as String,
    medicationIds: List<String>.from(json['medicationIds'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Indication copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorBand,
    List<String>? medicationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Indication(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    colorBand: colorBand ?? this.colorBand,
    medicationIds: medicationIds ?? this.medicationIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
