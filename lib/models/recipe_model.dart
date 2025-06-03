class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String type;
  final String? imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.type,
    this.imageUrl
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'type': type,
      'imageUrl': imageUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}