import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipe/models/meal_plan_model.dart';
import 'package:fp_recipe/models/recipe_model.dart';
import 'package:fp_recipe/services/recipe_service.dart';
// import 'package:uuid/uuid.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final Uuid _uuid = const Uuid();

  // Get current user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection references
  CollectionReference get _mealPlansRef => _firestore.collection('meal-plans');

  final RecipeService _recipeService = RecipeService();

  // Dummy recipes for testing
  // List<Recipe> getDummyRecipes() {
  //   return [
  //     Recipe(
  //       id: '1',
  //       name: 'Spicy Noodle Stir-fry',
  //       description: 'A quick and flavorful stir-fry with a kick.',
  //       types: ['Dinner', 'Asian'],
  //       imageUrl: 'https://example.com/spicy-noodle.jpg',
  //     ),
  //     Recipe(
  //       id: '2',
  //       name: 'Creamy Mushroom Pasta',
  //       description: 'Rich and savory pasta dish.',
  //       types: ['Dinner', 'Italian'],
  //       imageUrl: 'https://example.com/mushroom-pasta.jpg',
  //     ),
  //     Recipe(
  //       id: '3',
  //       name: 'Chicken Caesar Salad',
  //       description: 'Classic salad with grilled chicken.',
  //       types: ['Lunch', 'Salad'],
  //       imageUrl: 'https://example.com/caesar-salad.jpg',
  //     ),
  //     Recipe(
  //       id: '4',
  //       name: 'Vegetable Curry',
  //       description: 'Hearty and aromatic vegetable curry.',
  //       types: ['Dinner', 'Indian', 'Vegetarian'],
  //       imageUrl: 'https://example.com/vegetable-curry.jpg',
  //     ),
  //     Recipe(
  //       id: '5',
  //       name: 'Quinoa Bowl',
  //       description: 'Healthy and customizable grain bowl.',
  //       types: ['Lunch', 'Healthy', 'Vegetarian'],
  //       imageUrl: 'https://example.com/quinoa-bowl.jpg',
  //     ),
  //     Recipe(
  //       id: '6',
  //       name: 'Lentil Soup',
  //       description: 'Comforting and nutritious lentil soup.',
  //       types: ['Dinner', 'Soup', 'Vegetarian'],
  //       imageUrl: 'https://example.com/lentil-soup.jpg',
  //     ),
  //     Recipe(
  //       id: '7',
  //       name: 'Avocado Toast',
  //       description: 'Simple and nutritious breakfast option.',
  //       types: ['Breakfast', 'Vegetarian'],
  //       imageUrl: 'https://example.com/avocado-toast.jpg',
  //     ),
  //     Recipe(
  //       id: '8',
  //       name: 'Berry Smoothie Bowl',
  //       description: 'Refreshing and healthy breakfast bowl.',
  //       types: ['Breakfast', 'Vegetarian', 'Vegan'],
  //       imageUrl: 'https://example.com/smoothie-bowl.jpg',
  //     ),
  //     Recipe(
  //       id: '9',
  //       name: 'Grilled Salmon',
  //       description: 'Delicious and healthy grilled salmon fillet.',
  //       types: ['Dinner', 'Seafood'],
  //       imageUrl: 'https://example.com/grilled-salmon.jpg',
  //     ),
  //     Recipe(
  //       id: '10',
  //       name: 'Chocolate Mousse',
  //       description: 'Rich and decadent chocolate dessert.',
  //       types: ['Dessert'],
  //       imageUrl: 'https://example.com/chocolate-mousse.jpg',
  //     ),
  //   ];
  // }

  // Get meal plan for a specific date
  Future<MealPlan?> getMealPlanForDate(DateTime date) async {
    if (_userId.isEmpty) return null;

    // Normalize the date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final startOfDay = normalizedDate.millisecondsSinceEpoch;
    final endOfDay =
        DateTime(
          date.year,
          date.month,
          date.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch;

    try {
      final querySnapshot =
          await _mealPlansRef
              .where('userId', isEqualTo: _userId)
              .where('date', isGreaterThanOrEqualTo: startOfDay)
              .where('date', isLessThanOrEqualTo: endOfDay)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return MealPlan.empty(normalizedDate, _userId);
      }

      final doc = querySnapshot.docs.first;

      return MealPlan.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
        // getDummyRecipes(),
        await _recipeService.getUserRecipes(),
      );
    } catch (e) {
      print('Error getting meal plan: $e');
      return MealPlan.empty(normalizedDate, _userId);
    }
  }

  // Save a meal plan
  Future<bool> saveMealPlan(MealPlan mealPlan) async {
    if (_userId.isEmpty) {
      print('User ID is empty, cannot save meal plan');
      return false;
    }

    try {
      final data = mealPlan.toMap();
      print(
        'Saving meal plan: ${mealPlan.id}, Date: ${mealPlan.date}, Title: ${mealPlan.title}',
      );
      print('Data to save: $data');

      // Ensure userId is set
      if (data['userId'] == null || data['userId'].isEmpty) {
        data['userId'] = _userId;
        print('Setting userId to $_userId');
      }

      if (mealPlan.id != null && mealPlan.id!.isNotEmpty) {
        // Update existing meal plan
        print('Updating existing meal plan with ID: ${mealPlan.id}');
        await _mealPlansRef.doc(mealPlan.id).update(data);
        print('Successfully updated meal plan');
      } else {
        // Create new meal plan
        print('Creating new meal plan');
        final docRef = await _mealPlansRef.add(data);
        print('Created meal plan with ID: ${docRef.id}');
      }

      return true;
    } catch (e) {
      print('Error saving meal plan: $e');
      return false;
    }
  }

  // Add a recipe to a specific meal time
  MealPlan addRecipeToMealPlan(
    MealPlan mealPlan,
    MealTime mealTime,
    Recipe recipe,
  ) {
    // Create a copy of the meals map
    final updatedMeals = Map<MealTime, List<Recipe>>.from(mealPlan.meals);

    // Ensure the meal time exists in the map
    if (!updatedMeals.containsKey(mealTime)) {
      updatedMeals[mealTime] = [];
    }

    // Check if recipe already exists in this meal time
    if (!updatedMeals[mealTime]!.any((r) => r.id == recipe.id)) {
      updatedMeals[mealTime]!.add(recipe);
    }

    // Return a new MealPlan with the updated meals
    return MealPlan(
      id: mealPlan.id,
      date: mealPlan.date,
      title: mealPlan.title,
      description: mealPlan.description,
      meals: updatedMeals,
      userId: mealPlan.userId,
    );
  }

  // Remove a recipe from a meal plan
  MealPlan removeRecipeFromMealPlan(
    MealPlan mealPlan,
    MealTime mealTime,
    String recipeId,
  ) {
    // Create a copy of the meals map
    final updatedMeals = Map<MealTime, List<Recipe>>.from(mealPlan.meals);

    // Remove the recipe if it exists in this meal time
    if (updatedMeals.containsKey(mealTime)) {
      updatedMeals[mealTime] =
          updatedMeals[mealTime]!
              .where((recipe) => recipe.id != recipeId)
              .toList();
    }

    // Return a new MealPlan with the updated meals
    return MealPlan(
      id: mealPlan.id,
      date: mealPlan.date,
      title: mealPlan.title,
      description: mealPlan.description,
      meals: updatedMeals,
      userId: mealPlan.userId,
    );
  }

  // Get all meal plans for the current user
  Future<List<MealPlan>> getAllMealPlans() async {
    if (_userId.isEmpty) {
      print('User ID is empty, cannot fetch meal plans');
      return [];
    }

    try {
      print('Fetching meal plans for user: $_userId');

      final querySnapshot =
          await _mealPlansRef
              .where('userId', isEqualTo: _userId)
              .get(); // Remove orderBy to simplify the query

      print('Found ${querySnapshot.docs.length} meal plans for user $_userId');

      if (querySnapshot.docs.isEmpty) {
        print('No meal plans found in Firestore');
        return [];
      }

      final List<Recipe> allRecipes = await _recipeService.getUserRecipes();
      final Map<String, Recipe> recipeMap = {
        for (var recipe in allRecipes) recipe.id: recipe,
      };

      List<MealPlan> mealPlans = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing meal plan document: ${doc.id}');
          print('Document data: $data');

          // Ensure date exists and is valid
          if (!data.containsKey('date')) {
            print('Document ${doc.id} has no date field, skipping');
            continue;
          }

          // Create meals map from the document data
          Map<MealTime, List<Recipe>> mealsMap = {
            MealTime.morning: [],
            MealTime.afternoon: [],
            MealTime.night: [],
          };

          // Process morning recipes
          if (data.containsKey('morning') && data['morning'] is List) {
            List<String> morningIds = List<String>.from(data['morning']);
            print('Morning recipe IDs: $morningIds');

            for (var id in morningIds) {
              if (recipeMap.containsKey(id)) {
                mealsMap[MealTime.morning]!.add(recipeMap[id]!);
              } else {
                print('Recipe with ID $id not found in recipe map');
              }
            }
          }

          // Process afternoon recipes
          if (data.containsKey('afternoon') && data['afternoon'] is List) {
            List<String> afternoonIds = List<String>.from(data['afternoon']);
            print('Afternoon recipe IDs: $afternoonIds');

            for (var id in afternoonIds) {
              if (recipeMap.containsKey(id)) {
                mealsMap[MealTime.afternoon]!.add(recipeMap[id]!);
              } else {
                print('Recipe with ID $id not found in recipe map');
              }
            }
          }

          // Process night recipes
          if (data.containsKey('night') && data['night'] is List) {
            List<String> nightIds = List<String>.from(data['night']);
            print('Night recipe IDs: $nightIds');

            for (var id in nightIds) {
              if (recipeMap.containsKey(id)) {
                mealsMap[MealTime.night]!.add(recipeMap[id]!);
              } else {
                print('Recipe with ID $id not found in recipe map');
              }
            }
          }

          final mealPlan = MealPlan(
            id: doc.id,
            date: DateTime.fromMillisecondsSinceEpoch(data['date']),
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            meals: mealsMap,
            userId: data['userId'] ?? '',
          );

          print(
            'Successfully created meal plan object: ${mealPlan.id}, ${mealPlan.title}',
          );
          mealPlans.add(mealPlan);
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
        }
      }

      print('Returning ${mealPlans.length} meal plans');
      return mealPlans;
    } catch (e) {
      print('Error getting all meal plans: $e');
      return [];
    }
  }

  // Delete a meal plan
  Future<bool> deleteMealPlan(String mealPlanId) async {
    if (_userId.isEmpty || mealPlanId.isEmpty) return false;

    try {
      print('Deleting meal plan with ID: $mealPlanId');
      await _mealPlansRef.doc(mealPlanId).delete();
      print('Successfully deleted meal plan');
      return true;
    } catch (e) {
      print('Error deleting meal plan: $e');
      return false;
    }
  }
}
