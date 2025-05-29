class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  
  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
  
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }
}