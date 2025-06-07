import 'package:flutter/material.dart';
import 'package:fp_recipe/models/recipe_model.dart';
import 'package:fp_recipe/services/recipe_service.dart';
import 'package:intl/intl.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _currentRecipe;
  final RecipeService _recipeService = RecipeService();

  final List<String> _tabs = ['Ingredients', 'Instructions'];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_currentRecipe == null) {
      final recipe = ModalRoute.of(context)?.settings.arguments as Recipe?;

      if (recipe != null) {
        setState(() {
          _currentRecipe = recipe;
        });
      }
    }
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
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A9D8F), Color(0xFF264653)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

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
                      // Back button with custom style
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // More options menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (value == 'edit') {
                            // _showEditGroupDialog();
                          } else if (value == 'delete') {
                            _confirmDelete();
                          }
                        },
                        itemBuilder:
                            (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: Color(0xFF2A9D8F),
                              ),
                              title: Text('Edit Recipe'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text('Delete Recipe'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                (_currentRecipe!.imageUrl != null && _currentRecipe!.imageUrl!.isNotEmpty) ?
                  const SizedBox(height: 150)
                : Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,  // supaya tombol di kanan
                    children: [
                      InkWell(
                        onTap: () => {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,  // biar lebar container sesuai isi
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Add Image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.none,
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.only(top: 30),
                    // padding: const EdgeInsets.fromLTRB(
                    //   20,
                    //   30,
                    //   20,
                    //   20,
                    // ),
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _currentRecipe!.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A3136),
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _currentRecipe!.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A9D8F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF2A9D8F).withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: _getRecipeTypeIcon(_currentRecipe!.type)
                                ),
                                SizedBox(width: 8),
                                Text(
                                  toBeginningOfSentenceCase(_currentRecipe!.type) ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A9D8F).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: List.generate(
                                _tabs.length,
                                    (index) => Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTabIndex = index;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color:
                                        _selectedTabIndex == index
                                            ? Color(0xFF2A9D8F)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        _tabs[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                          _selectedTabIndex == index
                                              ? Colors.white
                                              : const Color(0xFF2A9D8F),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_selectedTabIndex == 0) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ingredients',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        "${_currentRecipe!.ingredients.length} ${_currentRecipe!.ingredients.length > 1 ? "Items" : "Item"}",
                                        style: TextStyle(
                                          color: Color(0xFF2A9D8F)
                                        ),
                                      )
                                    ]
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A9D8F),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Add To Shopping List",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            ..._currentRecipe!.ingredients.map((ingredient) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        toBeginningOfSentenceCase(ingredient.name),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${ingredient.quantity}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF2A9D8F),
                                            ),
                                            softWrap: true,
                                          ),
                                          Text(
                                            ingredient.unit,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF2A9D8F),
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          if (_selectedTabIndex == 1) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  Text(
                                    "${_currentRecipe!.instructions.length} ${_currentRecipe!.instructions.length > 1 ? "Steps" : "Step"}",
                                    style: TextStyle(
                                        color: Color(0xFF2A9D8F)
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            ..._currentRecipe!.instructions.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final instruction = entry.value;

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Step $index",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2A9D8F),
                                      ),
                                    ),
                                    Text(
                                      instruction,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
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

  void _confirmDelete() {
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
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  size: 40,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Recipe?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3136),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "${_currentRecipe!.name}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                        side: BorderSide(color: Color(0xFF2A9D8F)),
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
                      onPressed: () {
                        _recipeService
                            .deleteRecipe(_currentRecipe!.id)
                            .then((_) {
                          Navigator.pop(context); // Close dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recipe deleted successfully!'),
                              backgroundColor: Color(0xFF2A9D8F),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.pop(context, 'deleted'); // Go back to list
                        })
                            .catchError((e) {
                          Navigator.pop(context); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting list: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
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

  Icon _getRecipeTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icon(Icons.free_breakfast, color: Color(0xFF2A9D8F), size: 20);
      case 'lunch':
        return Icon(Icons.lunch_dining, color: Color(0xFF2A9D8F), size: 20);
      case 'dinner':
        return Icon(Icons.dinner_dining, color: Color(0xFF2A9D8F), size: 20);
      case 'snack':
        return Icon(Icons.cookie, color: Color(0xFF2A9D8F), size: 20);
      case 'dessert':
        return Icon(Icons.cake, color: Color(0xFF2A9D8F), size: 20);
      case 'appetizer':
        return Icon(Icons.tapas, color: Color(0xFF2A9D8F), size: 20);
      case 'beverage':
        return Icon(Icons.local_drink, color: Color(0xFF2A9D8F), size: 20);
      case 'salad':
        return Icon(Icons.eco, color: Color(0xFF2A9D8F), size: 20);
      default:
        return Icon(Icons.restaurant, color: Color(0xFF2A9D8F), size: 20);
    }
  }
}
