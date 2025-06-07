import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipe/models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _recipesCollection(String userId) =>
      _usersCollection.doc(userId).collection('recipes');

  Future<String> addRecipe(Recipe recipe) async {
    if (_userId.isEmpty) {
      throw Exception('User ID is empty');
    }

    try {
      final data = recipe.toMap();
      print('Data: $data');

      final docRef = await _recipesCollection(_userId).add(data);
      print('Created recipe with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Recipe>> getUserRecipes() async {
    if (_userId.isEmpty) {
      print('User ID is empty');
      return [];
    }

    final querySnapshot = await _recipesCollection(_userId)
        .orderBy('createdAt', descending: true)
        .get();

    final recipes = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Recipe.fromMap(data);
    }).toList();

    return recipes;
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (_userId.isEmpty) {
      print('User ID is empty');
    }

    try {
      await _recipesCollection(_userId).doc(recipeId).delete();
    } catch (e) {
      print('Error: $e');
    }
  }
}