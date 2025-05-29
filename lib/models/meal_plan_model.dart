import 'package:fp_recipe/models/recipe_model.dart';

/*
Note: This is a dummy model for the meal plan. The actual model will be implemented later by Karina.
 */

enum MealTime {
  morning,
  afternoon,
  night,
}

class MealPlan {
  final String? id;
  final DateTime date;
  final String title;
  final String description;
  final Map<MealTime, List<Recipe>> meals;
  final String userId;
  
  MealPlan({
    this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.meals,
    required this.userId,
  });
  
  Map<String, dynamic> toMap() {
    // Convert meals map to a format suitable for Firestore
    Map<String, List<String>> mealsMap = {};
    
    meals.forEach((mealTime, recipes) {
      String key = mealTime.toString().split('.').last;
      mealsMap[key] = recipes.map((recipe) => recipe.id).toList();
    });
    
    return {
      'date': date.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'morning': mealsMap['morning'] ?? [],
      'afternoon': mealsMap['afternoon'] ?? [],
      'night': mealsMap['night'] ?? [],
      'userId': userId,
    };
  }
  
  factory MealPlan.fromMap(Map<String, dynamic> map, String docId, List<Recipe> allRecipes) {
    // Create a map to quickly look up recipes by ID
    Map<String, Recipe> recipeMap = {
      for (var recipe in allRecipes) recipe.id: recipe
    };
    
    // Convert Firestore data to meals map
    Map<MealTime, List<Recipe>> mealsMap = {};
    
    // Process morning recipes
    if (map.containsKey('morning')) {
      List<String> morningIds = List<String>.from(map['morning'] ?? []);
      print('Morning recipe IDs: $morningIds');
      mealsMap[MealTime.morning] = morningIds
          .map((id) {
            final recipe = recipeMap[id];
            if (recipe == null) {
              print('Recipe with ID $id not found');
            }
            return recipe;
          })
          .whereType<Recipe>()
          .toList();
    } else {
      mealsMap[MealTime.morning] = [];
    }
    
    // Process afternoon recipes
    if (map.containsKey('afternoon')) {
      List<String> afternoonIds = List<String>.from(map['afternoon'] ?? []);
      print('Afternoon recipe IDs: $afternoonIds');
      mealsMap[MealTime.afternoon] = afternoonIds
          .map((id) {
            final recipe = recipeMap[id];
            if (recipe == null) {
              print('Recipe with ID $id not found');
            }
            return recipe;
          })
          .whereType<Recipe>()
          .toList();
    } else {
      mealsMap[MealTime.afternoon] = [];
    }
    
    // Process night recipes
    if (map.containsKey('night')) {
      List<String> nightIds = List<String>.from(map['night'] ?? []);
      print('Night recipe IDs: $nightIds');
      mealsMap[MealTime.night] = nightIds
          .map((id) {
            final recipe = recipeMap[id];
            if (recipe == null) {
              print('Recipe with ID $id not found');
            }
            return recipe;
          })
          .whereType<Recipe>()
          .toList();
    } else {
      mealsMap[MealTime.night] = [];
    }
    
    return MealPlan(
      id: docId,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      meals: mealsMap,
      userId: map['userId'] ?? '',
    );
  }
  
  // Create an empty meal plan for a specific date and user
  factory MealPlan.empty(DateTime date, String userId) {
    return MealPlan(
      date: date,
      title: '',
      description: '',
      meals: {
        MealTime.morning: [],
        MealTime.afternoon: [],
        MealTime.night: [],
      },
      userId: userId,
    );
  }
}
