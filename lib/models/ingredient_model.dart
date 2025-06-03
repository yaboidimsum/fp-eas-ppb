class Ingredient {
  double quantity;
  String unit;
  String name;

  Ingredient({
    required this.quantity,
    required this.unit,
    required this.name,
  });

  @override
  String toString() {
    return '$quantity $unit $name';
  }
}