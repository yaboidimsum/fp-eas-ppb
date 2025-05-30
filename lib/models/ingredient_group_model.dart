class IngredientGroupModel {
  final String id;
  final String title;
  final String? description;
  final String source; // "manual" or "api", etc.
  final DateTime createdAt;
  final String? imageUrl;

  IngredientGroupModel({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    DateTime? createdAt,
    this.imageUrl,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
    };
  }

  factory IngredientGroupModel.fromMap(Map<String, dynamic> map) {
    return IngredientGroupModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      source: map['source'] ?? 'manual',
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  // Create a copy with updated fields
  IngredientGroupModel copyWith({
    String? id,
    String? title,
    String? description,
    String? source,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return IngredientGroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
