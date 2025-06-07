import 'package:fp_recipe/models/recipe_ingredient_model.dart';

class Recipe {
  final String id;
  final String name;
  final String? description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final String type;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.type,
    this.imageUrl,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'instructions': instructions,
      'type': type,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromMap(e))
          .toList() ??
          [],
      instructions: List<String>.from(map['instructions'] ?? []),
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt:
      map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt:
      map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<String>? instructions,
    String? type,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
