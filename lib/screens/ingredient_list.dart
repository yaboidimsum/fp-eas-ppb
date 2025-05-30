import 'package:flutter/material.dart';
import 'package:fp_recipe/models/ingredient_group_model.dart';
import 'package:fp_recipe/models/ingredient_model.dart';
import 'package:fp_recipe/screens/ingredient_detail.dart';
import 'package:fp_recipe/services/ingredient_service.dart';
import 'package:uuid/uuid.dart';

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({super.key});

  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  final IngredientService _ingredientService = IngredientService();
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // Custom UI without traditional AppBar
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: () async {
            setState(() {});
          },
          child: StreamBuilder<List<IngredientGroupModel>>(
            stream: _ingredientService.getUserIngredientGroups(),
            builder: (context, groupsSnapshot) {
              if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (groupsSnapshot.hasError) {
                return Center(child: Text('Error: ${groupsSnapshot.error}'));
              }

              final groups = groupsSnapshot.data ?? [];

              if (groups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_basket,
                          size: 70,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No ingredient lists found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first ingredient list to get started',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _showAddGroupDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Create New List'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];

                  return StreamBuilder<List<IngredientItemModel>>(
                    stream: _ingredientService.getIngredientItems(group.id),
                    builder: (context, itemsSnapshot) {
                      // Count unchecked items for the badge
                      int totalItems = 0;
                      int uncheckedItems = 0;

                      if (itemsSnapshot.hasData) {
                        totalItems = itemsSnapshot.data!.length;
                        uncheckedItems =
                            itemsSnapshot.data!
                                .where((item) => !item.checked)
                                .length;
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.list_alt,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            group.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (group.description != null &&
                                  group.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(group.description!),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '$uncheckedItems of $totalItems items unchecked',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (uncheckedItems > 0)
                                Badge(
                                  label: Text(uncheckedItems.toString()),
                                  child: const Icon(Icons.shopping_cart),
                                )
                              else
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => IngredientDetailScreen(
                                      groupId: group.id,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGroupDialog,
        icon: const Icon(Icons.add),
        label: const Text('New List'),
        elevation: 4,
      ),
    );
  }

  void _showAddGroupDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Create New Ingredient List',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'List Title',
                    hintText: 'e.g., Sunday Lunch, Grocery List',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add notes about this list',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                // Create a new ingredient group
                final group = IngredientGroupModel(
                  id: _uuid.v4(),
                  title: titleController.text,
                  description:
                      descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                  source: 'manual',
                );

                try {
                  final groupId = await _ingredientService.addIngredientGroup(
                    group,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    // Navigate to the detail screen to add ingredients
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                IngredientDetailScreen(groupId: groupId),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating list: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
