class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> types;
  final String? imageUrl;
  
  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.types,
    this.imageUrl,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'types': types,
      'imageUrl': imageUrl,
    };
  }
  
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      types: List<String>.from(map['types'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }
}