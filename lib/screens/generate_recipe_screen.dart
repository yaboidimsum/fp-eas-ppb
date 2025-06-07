import 'package:flutter/material.dart';
import 'package:fp_recipe/models/recipe_ingredient_model.dart';
import 'package:fp_recipe/services/api_service.dart';
import 'package:fp_recipe/services/recipe_service.dart';
import 'package:intl/intl.dart';
import 'package:fp_recipe/models/recipe_model.dart';
import 'dart:convert';

class GenerateRecipeScreen extends StatefulWidget {
  const GenerateRecipeScreen({super.key});

  @override
  State<GenerateRecipeScreen> createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSaving = false;
  String _generatedRecipe = '';

  final List<String> _recipeTypes = [
    'breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'appetizer', 'beverage', 'salad'
  ];

  final Map<String, String> _recipeTypeLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
    'dessert': 'Dessert',
    'appetizer': 'Appetizer',
    'beverage': 'Beverage',
    'salad': 'Salad'
  };

  String _selectedRecipeType = 'lunch';

  final List<RecipeIngredient> _ingredients = [
    RecipeIngredient(quantity: 0.0, unit: '', name: ''),
  ];

  void _addIngredient() {
    setState(() {
      _ingredients.add(
        RecipeIngredient(quantity: 0.0, unit: 'pcs', name: ''),
      );
    });
  }

  bool _isValidIngredient(RecipeIngredient ingredient) {
    return ingredient.unit.trim().isNotEmpty &&
        ingredient.name.trim().isNotEmpty &&
        ingredient.quantity > 0;
  }

  bool _hasValidIngredients() {
    return _ingredients.any(_isValidIngredient);
  }

  String _getIngredientsText() {
    return _ingredients
        .where(_isValidIngredient)
        .map((ingredient) => ingredient.toString())
        .join(', ');
  }

  Future<void> _generateRecipe() async {
    if (!_hasValidIngredients()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter at least one complete ingredient!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedRecipe = '';
    });

    try {
      final ingredientsText = _getIngredientsText();
      print(ingredientsText);
      final recipe = await _apiService.generateRecipe(ingredientsText, _selectedRecipeType);
      setState(() {
        _generatedRecipe = recipe;
      });
    } catch (e) {
      setState(() {
        _generatedRecipe = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _parseRecipeJson(String recipeText) {
    try {
      // Try to find JSON object in the response
      String jsonString = recipeText.trim();

      // If response contains extra text before/after JSON, extract JSON part
      int startIndex = jsonString.indexOf('{');
      int endIndex = jsonString.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        return null;
      }

      jsonString = jsonString.substring(startIndex, endIndex + 1);

      // Parse JSON
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract and format data
      String name = jsonData['name'] ?? '';
      String description = jsonData['description'] ?? '';

      List<Map<String, dynamic>> ingredients = [];
      if (jsonData['ingredients'] != null) {
        ingredients = List<Map<String, dynamic>>.from(jsonData['ingredients']);
      }

      List<String> steps = [];
      if (jsonData['steps'] != null) {
        steps = List<String>.from(jsonData['steps']);
      }

      return {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
      };
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    // final isNewMealPlan = _currentMealPlan?.id == null;

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          // minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title and subtitle
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Generate Recipe',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main form content area
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(top: 24),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          30,
                          20,
                          20,
                        ), // Adjusted padding
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
                                  Text(
                                    "Meal Type", // Section title
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A3136),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRecipeType,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF2A9D8F),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      items: _recipeTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Row(
                                            children: [
                                              _getRecipeTypeIcon(type),
                                              SizedBox(width: 8),
                                              Text(_recipeTypeLabels[type] ?? type),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRecipeType = newValue ?? 'lunch';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Ingredient List", // Section title
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2A3136),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _addIngredient,
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFF2A9D8F),
                                        ),
                                        tooltip: 'Add Ingredient',
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2A9D8F,
                                          ).withOpacity(0.1), // Subtle background
                                          padding: const EdgeInsets.all(8),
                                          shape: const CircleBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ...List.generate(_ingredients.length, _buildIngredientItem),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _generateRecipe,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A9D8F),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isLoading ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Generating...'),
                                      ],
                                    )
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.auto_awesome, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Generate Recipe'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_generatedRecipe.isNotEmpty && !_isLoading) _buildResultCard(),
                                ]
                            )
                        )
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    Map<String, dynamic>? recipeData = _parseRecipeJson(_generatedRecipe);

    if (recipeData == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            SizedBox(height: 8),
            Text(
              'Gagal memproses resep',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Silakan coba lagi nanti',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE8EFEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_generatedRecipe.isNotEmpty && !_isLoading)
                Expanded(
                  child: Text(
                    recipeData['name'],
                    style: _sectionTitleStyle(),
                    softWrap: true,
                  ),
                ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveRecipe,
                icon: _isSaving ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)
                  ),
                )
                    : Icon(Icons.save, size: 16),
                label: Text(_isSaving ? 'Saving...' : 'Save'),
                style: _buttonStyle(Colors.green, fontSize: 12, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ],
          ),
          SizedBox(height: 12),
          _isLoading ? _loadingMessage() : _buildRecipeContent(recipeData),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (_generatedRecipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generate recipe terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Parse recipe dari JSON response
      Map<String, dynamic>? recipeData = _parseRecipeJson(_generatedRecipe);

      if (recipeData == null) {
        _showErrorSnackBar('Gagal memproses resep. Silakan coba lagi nanti.');
        return;
      }

      List<RecipeIngredient> ingredientsList = [];
      if (recipeData['ingredients'] != null) {
        ingredientsList = (recipeData['ingredients'] as List).map((item) {
          return RecipeIngredient(
            quantity: (item['quantity'] as num?)?.toDouble() ?? 0.0,
            unit: item['unit'] ?? '',
            name: item['name'] ?? '',
          );
        }).toList();
      }

      Recipe recipe = Recipe(
        id: '',
        name: recipeData['name'] ?? 'Generated Recipe',
        description: recipeData['description'],
        ingredients: ingredientsList,
        steps: List<String>.from(recipeData['steps'] ?? []),
        type: _selectedRecipeType,
        imageUrl: null,
      );

      print(recipe);
      await _recipeService.addRecipe(recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resep berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan resep: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  TextStyle _sectionTitleStyle() => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.grey[800],
  );

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildRecipeContent(Map<String, dynamic> recipeData) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipeData["description"],
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
            ),
            SizedBox(height: 10),
            Text(
              'Ingredients',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 4),
            Text(
              recipeData["ingredients"]
                  .map((ingredient) =>
              "${ingredient['quantity']} ${ingredient['unit']} ${ingredient['name']}")
                  .join('\n'),
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
            ),
            SizedBox(height: 10),
            Text(
              'Steps',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 4),
            Text(
              recipeData["steps"].asMap().entries
                  .map((entry) => "${entry.key + 1}. ${entry.value}")
                  .join('\n'),
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
            )
          ],
        ),
      ),
    );
  }

  Widget _loadingMessage() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
          SizedBox(height: 12),
          Text(
            'Generating your ${_recipeTypeLabels[_selectedRecipeType]?.toLowerCase()} recipe...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, {double fontSize = 14, EdgeInsets? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: padding ?? EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: TextStyle(fontSize: fontSize),
      elevation: 2,
    );
  }

  Widget _buildIngredientItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Quantity Input
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'e.g., 2',
                labelStyle: const TextStyle(
                  color: Color(0xFF2A9D8F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A9D8F),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  _ingredients[index].quantity = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Unit Dropdown
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g., kg',
                labelStyle: const TextStyle(
                  color: Color(0xFF2A9D8F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A9D8F),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _ingredients[index].unit = value;
                });
              },
            ),
          ),

          SizedBox(width: 8),

          // Ingredient Name Input
          Expanded(
            flex: 5,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Tomatoes',
                labelStyle: const TextStyle(
                    color: Color(0xFF2A9D8F)
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A9D8F),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _ingredients[index].name = value;
                });
              },
            ),
          ),

          SizedBox(width: 8),

          // Remove Button
          if (_ingredients.length > 1)
            IconButton(
              onPressed: () {
                setState(() {
                  _ingredients.removeAt(index);
                });
              },
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
              ),
            ),
        ],
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