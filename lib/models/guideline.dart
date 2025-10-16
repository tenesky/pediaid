class Guideline {
  final String id;
  final String title;
  final String summary;
  final String details;
  final String source;
  /// Optionales Icon, das zur visuellen Darstellung genutzt werden kann.
  final String? iconName;

  Guideline({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
    required this.source,
    this.iconName,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) {
    return Guideline(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      details: json['details'] as String,
      source: json['source'] as String,
      iconName: json['iconName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'summary': summary,
      'details': details,
      'source': source,
    };
    if (iconName != null) map['iconName'] = iconName;
    return map;
  }
}