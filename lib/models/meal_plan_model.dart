import 'package:fp_recipe/models/recipe_model.dart';

/*
Note: This is a dummy model for the meal plan. The actual model will be implemented later by Karina.
 */

enum MealTime { morning, afternoon, night }

class MealPlan {
  final String id;
  final DateTime date;
  final Map<MealTime, List<Recipe>> meals;

  MealPlan({required this.id, required this.date, required this.meals});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'meals': meals.map(
        (key, value) => MapEntry(
          key.toString().split('.').last,
          value.map((recipe) => recipe.toMap()).toList(),
        ),
      ),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    Map<MealTime, List<Recipe>> mealsMap = {};

    (map['meals'] as Map<String, dynamic>).forEach((key, value) {
      MealTime mealTime = MealTime.values.firstWhere(
        (e) => e.toString().split('.').last == key,
      );

      List<Recipe> recipes =
          (value as List)
              .map((recipeMap) => Recipe.fromMap(recipeMap))
              .toList();

      mealsMap[mealTime] = recipes;
    });

    return MealPlan(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      meals: mealsMap,
    );
  }

  // Create an empty meal plan for a specific date
  factory MealPlan.empty(String id, DateTime date) {
    return MealPlan(
      id: id,
      date: date,
      meals: {MealTime.morning: [], MealTime.afternoon: [], MealTime.night: []},
    );
  }
}
