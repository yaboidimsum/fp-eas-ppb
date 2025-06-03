class IngredientItemModel {
  final String id;
  final String groupId; // References the parent IngredientGroup
  final String name;
  final String quantity;
  final String? unit;
  bool checked;
  final DateTime createdAt;

  IngredientItemModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.quantity,
    this.unit,
    this.checked = false,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'checked': checked,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory IngredientItemModel.fromMap(Map<String, dynamic> map) {
    return IngredientItemModel(
      id: map['id'] ?? '',
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      unit: map['unit'],
      checked: map['checked'] ?? false,
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.now(),
    );
  }
  // Create a copy with updated fields
  IngredientItemModel copyWith({
    String? id,
    String? groupId,
    String? name,
    String? quantity,
    String? unit,
    bool? checked,
    DateTime? createdAt,
  }) {
    return IngredientItemModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
