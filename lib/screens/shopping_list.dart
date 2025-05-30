import 'package:flutter/material.dart';
import 'package:fp_recipe/models/ingredient_group_model.dart';
import 'package:fp_recipe/models/ingredient_model.dart';
import 'package:fp_recipe/screens/ingredient_detail.dart';
import 'package:fp_recipe/services/ingredient_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final IngredientService _ingredientService = IngredientService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _showMarkAllDialog(),
            tooltip: 'Mark all as purchased',
            iconSize: 26,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh list',
            iconSize: 26,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<List<IngredientItemModel>>(
          stream: _ingredientService.getAllUncheckedItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        size: 80,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your shopping list is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Add ingredients to your lists and they\'ll appear here when unchecked',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed:
                          () => Navigator.pushNamed(context, 'ingredients'),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Go to Ingredients'),
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

            // Group the items by their groupId for better organization
            final Map<String, List<IngredientItemWithGroup>> groupedItems = {};

            // First pass: get all group IDs
            final Set<String> groupIds =
                items.map((item) => item.groupId).toSet();

            return FutureBuilder(
              future: Future.wait(
                groupIds.map(
                  (groupId) => _ingredientService.getIngredientGroup(groupId),
                ),
              ),
              builder: (context, groupsSnapshot) {
                if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups =
                    groupsSnapshot.data as List<IngredientGroupModel?>;

                // Create a map of groupId to group for easy lookup
                final Map<String, IngredientGroupModel> groupMap = {};
                for (final group in groups) {
                  if (group != null) {
                    groupMap[group.id] = group;
                  }
                }

                // Group items with their groups
                for (final item in items) {
                  final group = groupMap[item.groupId];
                  if (group != null) {
                    if (!groupedItems.containsKey(item.groupId)) {
                      groupedItems[item.groupId] = [];
                    }

                    groupedItems[item.groupId]!.add(
                      IngredientItemWithGroup(item: item, group: group),
                    );
                  }
                }
                // Convert to a list of entries for the ListView
                final groupEntries = groupedItems.entries.toList();

                return ListView.builder(
                  itemCount: groupEntries.length,
                  itemBuilder: (context, index) {
                    final groupItems = groupEntries[index].value;

                    // All items in this list have the same group
                    final group = groupItems.first.group;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group header
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                              title: Text(
                                group.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.list_alt,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
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
                              subtitle: Text(
                                "${groupItems.length} items",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),

                          const Divider(height: 1),

                          // Group items
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupItems.length,
                            itemBuilder: (context, itemIndex) {
                              final itemWithGroup = groupItems[itemIndex];
                              final item = itemWithGroup.item;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: ListTile(
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      decoration:
                                          item.checked
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                      color:
                                          item.checked
                                              ? Colors.grey
                                              : Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                          if (item.quantity.isNotEmpty)
                                            item.quantity,
                                          item.unit,
                                        ]
                                        .where((e) => e != null && e.isNotEmpty)
                                        .join(' '),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      decoration:
                                          item.checked
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                    ),
                                  ),
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          item.checked
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      item.checked
                                          ? Icons.check_circle
                                          : Icons.shopping_cart,
                                      color:
                                          item.checked
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: item.checked,
                                    activeColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _toggleItemStatus(item.id, value);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _toggleItemStatus(String itemId, bool checked) async {
    try {
      await _ingredientService.updateIngredientCheckedStatus(itemId, checked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating ingredient: $e')),
        );
      }
    }
  }

  void _showMarkAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Mark All as Purchased?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Would you like to mark all items in your shopping list as purchased?',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel', style: TextStyle(fontSize: 15)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                );

                // Get all unchecked items
                final items =
                    await _ingredientService.getAllUncheckedItems().first;

                // Mark them all as checked
                for (final item in items) {
                  await _ingredientService.updateIngredientCheckedStatus(
                    item.id,
                    true,
                  );
                }

                if (mounted) {
                  // Close loading dialog
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text('All items marked as purchased'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(12),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Mark All',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class IngredientItemWithGroup {
  final IngredientItemModel item;
  final IngredientGroupModel group;

  IngredientItemWithGroup({required this.item, required this.group});
}
