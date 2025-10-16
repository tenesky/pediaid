class Checklist {
  final String id;
  final String title;
  final List<String> steps;
  final String description;
  final String source;

  Checklist({
    required this.id,
    required this.title,
    required this.steps,
    required this.description,
    required this.source,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List<dynamic>).map((e) => e as String).toList();
    return Checklist(
      id: json['id'] as String,
      title: json['title'] as String,
      steps: steps,
      description: json['description'] as String,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'steps': steps,
    'description': description,
    'source': source,
  };
}