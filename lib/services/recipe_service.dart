import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipe/models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _recipesCollection => _firestore.collection('recipes');

  Future<String> createRecipe(Recipe recipe) async {
    try {
      if (_userId == '') {
        throw Exception('User not authenticated');
      }

      // Add user ID to recipe data
      Map<String, dynamic> recipeData = recipe.toMap();
      recipeData['userId'] = _userId;

      DocumentReference docRef = await _recipesCollection.add(recipeData);
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat resep: $e');
    }
  }

  Stream<List<Recipe>> getUserRecipes() {
    if (_userId == '') {
      return Stream.value([]);
    }

    return _recipesCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Set document ID
        return Recipe.fromMap(data);
      }).toList();
    });
  }

  // Get single recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      DocumentSnapshot doc = await _recipesCollection.doc(recipeId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Recipe.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil resep: $e');
    }
  }

  // Update recipe
  Future<void> updateRecipe(String recipeId, Recipe recipe) async {
    try {
      if (_userId == '') {
        throw Exception('User not authenticated');
      }

      Map<String, dynamic> recipeData = recipe.toMap();
      // recipeData['updatedAt'] = FieldValue.serverTimestamp();

      await _recipesCollection.doc(recipeId).update(recipeData);
    } catch (e) {
      throw Exception('Gagal mengupdate resep: $e');
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      if (_userId == '') {
        throw Exception('User not authenticated');
      }

      // Verify recipe belongs to current user
      DocumentSnapshot doc = await _recipesCollection.doc(recipeId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['userId'] == _userId) {
          await _recipesCollection.doc(recipeId).delete();
        } else {
          throw Exception('Tidak memiliki izin untuk menghapus resep ini');
        }
      } else {
        throw Exception('Resep tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Gagal menghapus resep: $e');
    }
  }

  // Search recipes by title
  Stream<List<Recipe>> searchRecipes(String query) {
    if (_userId == '' || query.isEmpty) {
      return Stream.value([]);
    }

    return _recipesCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Recipe.fromMap(data);
      }).toList();
    });
  }

  // Get recipes count
  Future<int> getRecipesCount() async {
    if (_userId == '') return 0;

    try {
      QuerySnapshot snapshot = await _recipesCollection
          .where('userId', isEqualTo: _userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}