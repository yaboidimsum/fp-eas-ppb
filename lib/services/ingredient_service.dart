import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipe/models/ingredient_group_model.dart';
import 'package:fp_recipe/models/ingredient_model.dart';
import 'package:uuid/uuid.dart';

class IngredientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _ingredientGroupsCollection(String userId) =>
      _usersCollection.doc(userId).collection('ingredientGroups');

  CollectionReference _ingredientItemsCollection(String userId) =>
      _usersCollection.doc(userId).collection('ingredientItems');

  // Get all ingredient groups for the current user
  Stream<List<IngredientGroupModel>> getUserIngredientGroups() {
    if (currentUserId == null) return Stream.value([]);

    return _ingredientGroupsCollection(
      currentUserId!,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return IngredientGroupModel.fromMap(data);
      }).toList();
    });
  }

  // Get a specific ingredient group
  Future<IngredientGroupModel?> getIngredientGroup(String groupId) async {
    if (currentUserId == null) return null;

    DocumentSnapshot doc =
        await _ingredientGroupsCollection(currentUserId!).doc(groupId).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return IngredientGroupModel.fromMap(data);
    }
    return null;
  }

  // Get all ingredient items for a specific group
  Stream<List<IngredientItemModel>> getIngredientItems(String groupId) {
    if (currentUserId == null) return Stream.value([]);

    return _ingredientItemsCollection(currentUserId!)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return IngredientItemModel.fromMap(data);
          }).toList();
        });
  }

  // Get all ingredient items for shopping list
  Stream<List<IngredientItemModel>> getAllUncheckedItems() {
    if (currentUserId == null) return Stream.value([]);

    return _ingredientItemsCollection(
      currentUserId!,
    ).where('checked', isEqualTo: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return IngredientItemModel.fromMap(data);
      }).toList();
    });
  }

  // Add a new ingredient group
  Future<String> addIngredientGroup(IngredientGroupModel group) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    DocumentReference docRef = await _ingredientGroupsCollection(
      currentUserId!,
    ).add(group.toMap());

    return docRef.id;
  }

  // Add a new ingredient item
  Future<String> addIngredientItem(IngredientItemModel item) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    DocumentReference docRef = await _ingredientItemsCollection(
      currentUserId!,
    ).add(item.toMap());

    return docRef.id;
  }

  // Update an ingredient group
  Future<void> updateIngredientGroup(IngredientGroupModel group) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _ingredientGroupsCollection(
      currentUserId!,
    ).doc(group.id).update(group.toMap());
  }

  // Update an ingredient item
  Future<void> updateIngredientItem(IngredientItemModel item) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _ingredientItemsCollection(
      currentUserId!,
    ).doc(item.id).update(item.toMap());
  }

  // Update ingredient's checked status
  Future<void> updateIngredientCheckedStatus(
    String itemId,
    bool checked,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _ingredientItemsCollection(
      currentUserId!,
    ).doc(itemId).update({'checked': checked});
  }

  // Delete an ingredient group and all its items
  Future<void> deleteIngredientGroup(String groupId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Delete all ingredient items with this groupId
    final querySnapshot =
        await _ingredientItemsCollection(
          currentUserId!,
        ).where('groupId', isEqualTo: groupId).get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the group itself
    batch.delete(_ingredientGroupsCollection(currentUserId!).doc(groupId));

    await batch.commit();
  }

  // Delete an ingredient item
  Future<void> deleteIngredientItem(String itemId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _ingredientItemsCollection(currentUserId!).doc(itemId).delete();
  }

  // Create a new ingredient group with items
  Future<String> createGroupWithItems({
    required String title,
    required String source,
    String? description,
    required List<Map<String, dynamic>> items,
    String? imageUrl,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Create ingredient group
    final group = IngredientGroupModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      source: source,
      imageUrl: imageUrl,
    );

    final groupId = await addIngredientGroup(group);

    // Add all ingredient items
    final batch = _firestore.batch();

    for (var itemData in items) {
      final item = IngredientItemModel(
        id: _uuid.v4(),
        groupId: groupId,
        name: itemData['name'],
        quantity: itemData['quantity'] ?? '',
        unit: itemData['unit'],
      );

      batch.set(
        _ingredientItemsCollection(currentUserId!).doc(item.id),
        item.toMap(),
      );
    }

    await batch.commit();
    return groupId;
  }

  // Mark all items in a group as checked/unchecked
  Future<void> markAllItemsInGroup(String groupId, bool checked) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final querySnapshot =
        await _ingredientItemsCollection(
          currentUserId!,
        ).where('groupId', isEqualTo: groupId).get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'checked': checked});
    }

    await batch.commit();
  }
}
