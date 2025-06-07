class RecipeIngredient {
  String name;
  double quantity;
  String unit;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0.0,
      unit: map['unit'],
    );
  }

  @override
  String toString() {
    return '$quantity $unit $name';
  }
}
