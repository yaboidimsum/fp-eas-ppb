// Modern shopping list implementation
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fp_recipe/models/ingredient_group_model.dart';
import 'package:fp_recipe/models/ingredient_model.dart';
import 'package:fp_recipe/screens/ingredient_detail_modern.dart';
import 'package:fp_recipe/services/ingredient_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  final IngredientService _ingredientService = IngredientService();
  late AnimationController _animationController;
  Map<String, IngredientGroupModel> _groupCache = {};
  List<String> _expandedGroups = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadGroups();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _isRefreshing = true);
    final groupStream = _ingredientService.getUserIngredientGroups();
    await for (final groups in groupStream) {
      for (var group in groups) {
        _groupCache[group.id] = group;
      }
      break; // Just need to load once
    }
    setState(() => _isRefreshing = false);
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadGroups();
    setState(() => _isRefreshing = false);
  }

  void _toggleGroupExpansion(String groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          // Background gradient top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF264653), Color(0xFF2A9D8F)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Shopping List",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Image.network(
                                'https://em-content.zobj.net/source/apple/354/shopping-cart_1f6d2.png',
                                height: 24,
                              ),
                            ],
                          ),
                          const Text(
                            "All your items to purchase in one place",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),

                      // Actions
                      Row(
                        children: [
                          // Refresh button
                          IconButton(
                            onPressed: _refreshData,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mark all button
                          IconButton(
                            onPressed: _showMarkAllDialog,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Color(0xFF2A9D8F)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search for items...",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main content area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.only(top: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Items to Buy",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A3136),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2A9D8F,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.sort,
                                      color: Color(0xFF2A9D8F),
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Group by List",
                                      style: TextStyle(
                                        color: Color(0xFF2A9D8F),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: RefreshIndicator(
                            color: const Color(0xFF2A9D8F),
                            onRefresh: _refreshData,
                            child: StreamBuilder<List<IngredientItemModel>>(
                              stream: _ingredientService.getAllUncheckedItems(),
                              builder: (context, snapshot) {
                                if (_isRefreshing ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF2A9D8F),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                final items = snapshot.data ?? [];

                                if (items.isEmpty) {
                                  return _buildEmptyState();
                                }

                                // Group items by their list
                                final groupedItems =
                                    <String, List<IngredientItemModel>>{};
                                for (var item in items) {
                                  if (!groupedItems.containsKey(item.groupId)) {
                                    groupedItems[item.groupId] = [];
                                  }
                                  groupedItems[item.groupId]!.add(item);
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    20,
                                  ),
                                  itemCount: groupedItems.length,
                                  itemBuilder: (context, index) {
                                    final groupId = groupedItems.keys.elementAt(
                                      index,
                                    );
                                    final groupItems = groupedItems[groupId]!;
                                    final group = _groupCache[groupId];
                                    final isExpanded = _expandedGroups.contains(
                                      groupId,
                                    );

                                    return _buildGroupCard(
                                      group,
                                      groupItems,
                                      isExpanded,
                                      index,
                                      groupedItems.length,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A9D8F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Color(0xFF2A9D8F),
            ),
          ),
          const Text(
            "Your Shopping List is Empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3136),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Add ingredients to your lists and they'll appear here when unchecked",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, 'ingredients'),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Go to Ingredients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A9D8F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    IngredientGroupModel? group,
    List<IngredientItemModel> items,
    bool isExpanded,
    int index,
    int totalGroups,
  ) {
    final animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index / math.max(1, totalGroups),
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Group header
              InkWell(
                onTap: () => _toggleGroupExpansion(items.first.groupId),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(isExpanded ? 0 : 16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A9D8F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getEmojiForList(group?.title ?? 'Shopping List'),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group?.title ?? 'Shopping List',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A3136),
                              ),
                            ),
                            Text(
                              '${items.length} ${items.length == 1 ? 'item' : 'items'} to buy',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF2A9D8F),
                        ),
                        onPressed:
                            () => _toggleGroupExpansion(items.first.groupId),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          color: Color(0xFF2A9D8F),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (_, __, ___) => IngredientDetailScreen(
                                    groupId: items.first.groupId,
                                  ),
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded items
              if (isExpanded)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildShoppingItem(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingItem(IngredientItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () => _toggleItemChecked(item),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A9D8F), width: 2),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A3136),
                  ),
                ),
                if (item.quantity.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.unit != null
                          ? '${item.quantity} ${item.unit}'
                          : item.quantity,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmojiForList(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('fruit') || lowerTitle.contains('vegetable')) {
      return '🥬';
    } else if (lowerTitle.contains('meat')) {
      return '🥩';
    } else if (lowerTitle.contains('dairy')) {
      return '🧀';
    } else if (lowerTitle.contains('bakery') || lowerTitle.contains('bread')) {
      return '🥐';
    } else if (lowerTitle.contains('spice')) {
      return '🌶️';
    } else if (lowerTitle.contains('drink') ||
        lowerTitle.contains('beverage')) {
      return '🥤';
    } else if (lowerTitle.contains('snack')) {
      return '🍿';
    }
    return '🛒';
  }

  // CRUD Operations
  Future<void> _toggleItemChecked(IngredientItemModel item) async {
    try {
      final updatedItem = IngredientItemModel(
        id: item.id,
        groupId: item.groupId,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        checked: !item.checked,
      );
      await _ingredientService.updateIngredientItem(updatedItem);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showMarkAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A9D8F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 40,
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mark All Items?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3136),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Do you want to mark all shopping list items as purchased? This will affect all your ingredient lists.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF2A9D8F)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              // Get all unchecked items
                              final items =
                                  await _ingredientService
                                      .getAllUncheckedItems()
                                      .first;

                              // Group them by groupId for efficiency
                              final groupIds = <String>{};
                              for (var item in items) {
                                groupIds.add(item.groupId);
                              }

                              // Mark all items in each group
                              for (var groupId in groupIds) {
                                await _ingredientService.markAllItemsInGroup(
                                  groupId,
                                  true,
                                );
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'All items marked as purchased',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Color(0xFF2A9D8F),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A9D8F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Mark All'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
