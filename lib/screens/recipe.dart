import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final ApiService _apiService = ApiService();
  final RecipeService _recipeService = RecipeService();
  final Uuid _uuid = Uuid();

  List<Ingredient> _ingredients = [
    Ingredient(quantity: 0, unit: 'pcs', name: ''),
  ];

  final List<String> _units = [
    'pcs', 'gr', 'kg', 'ml', 'l', 'tbs', 'tsp', 'cup', 'slice', 'clove', 'bunch'
  ];

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
  String _generatedRecipe = '';
  bool _isLoading = false;
  bool _isSaving = false;

  void _addIngredient() {
    setState(() {
      _ingredients.add(
        Ingredient(quantity: 0, unit: 'pcs', name: ''),
      );
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  String _getIngredientsText() {
    return _ingredients
        .where((ingredient) =>
    ingredient.name.trim().isNotEmpty && ingredient.quantity > 0)
        .map((ingredient) => ingredient.toString())
        .join(', ');
  }

  bool _hasValidIngredients() {
    return _ingredients.any((ingredient) =>
    ingredient.name.trim().isNotEmpty && ingredient.quantity > 0);
  }

  Future<void> _generateRecipe() async {
    if (!_hasValidIngredients()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan minimal satu bahan yang lengkap!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedRecipe = '';
    });

    try {
      final ingredientsText = _getIngredientsText();
      final recipe = await _apiService.generateRecipe(ingredientsText, _selectedRecipeType);
      setState(() {
        _generatedRecipe = recipe;
      });
    } catch (e) {
      setState(() {
        _generatedRecipe = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      Map<String, dynamic> recipeData = _parseRecipeJson(_generatedRecipe);

      // Generate UUID for the recipe
      String recipeId = _uuid.v4();

      Recipe recipe = Recipe(
        id: recipeId, // Use generated UUID
        title: recipeData['title'] ?? 'Generated Recipe',
        ingredients: recipeData['ingredients'] ?? [],
        steps: recipeData['instructions'] ?? [],
        type: _selectedRecipeType, // Use selected recipe type
      );

      // Create recipe with UUID
      await _recipeService.createRecipe(recipe);

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

  Map<String, dynamic> _parseRecipeJson(String recipeText) {
    try {
      // Try to find JSON object in the response
      String jsonString = recipeText.trim();

      // If response contains extra text before/after JSON, extract JSON part
      int startIndex = jsonString.indexOf('{');
      int endIndex = jsonString.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonString = jsonString.substring(startIndex, endIndex + 1);
      }

      // Parse JSON
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract and format data
      String title = jsonData['recipe_name'] ?? 'Generated Recipe';

      List<String> ingredients = [];
      if (jsonData['ingredients'] != null) {
        ingredients = List<String>.from(jsonData['ingredients']);
      }

      List<String> instructions = [];
      if (jsonData['instructions'] != null) {
        instructions = List<String>.from(jsonData['instructions']);
      }

      return {
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
      };

    } catch (e) {
      print('Error parsing JSON: $e');
      // Fallback to old parsing method if JSON parsing fails
      return {
        'title': _extractRecipeTitleFallback(recipeText),
        'ingredients': _extractIngredientsFallback(recipeText),
        'instructions': _extractStepsFallback(recipeText),
      };
    }
  }

  // Fallback parsing methods for non-JSON responses
  String _extractRecipeTitleFallback(String recipe) {
    final lines = recipe.split('\n');
    for (String line in lines) {
      if (line.toLowerCase().contains('recipe name:') ||
          line.toLowerCase().contains('nama resep:')) {
        return line.split(':')[1].trim();
      }
    }
    return 'Generated Recipe';
  }

  List<String> _extractIngredientsFallback(String recipe) {
    List<String> ingredients = [];
    final lines = recipe.split('\n');
    bool inIngredients = false;

    for (String line in lines) {
      if (line.toLowerCase().contains('ingredients:') ||
          line.toLowerCase().contains('bahan:')) {
        inIngredients = true;
        continue;
      }

      if (inIngredients) {
        if (line.toLowerCase().contains('instructions:') ||
            line.toLowerCase().contains('langkah:') ||
            line.toLowerCase().contains('cara:')) {
          break;
        }

        if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
          ingredients.add(line.trim().substring(1).trim());
        }
      }
    }

    return ingredients.isNotEmpty ? ingredients : ['Ingredients not parsed correctly'];
  }

  List<String> _extractStepsFallback(String recipe) {
    List<String> steps = [];
    final lines = recipe.split('\n');
    bool inSteps = false;

    for (String line in lines) {
      if (line.toLowerCase().contains('instructions:') ||
          line.toLowerCase().contains('langkah:') ||
          line.toLowerCase().contains('cara:')) {
        inSteps = true;
        continue;
      }

      if (inSteps && line.trim().isNotEmpty) {
        // Remove numbering if present
        String step = line.trim();
        if (RegExp(r'^\d+\.').hasMatch(step)) {
          step = step.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        }
        if (step.isNotEmpty) {
          steps.add(step);
        }
      }
    }

    return steps.isNotEmpty ? steps : ['Steps not parsed correctly'];
  }

  Widget _buildIngredientItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Quantity Input
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  _ingredients[index].quantity = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),

          SizedBox(width: 8),

          // Unit Dropdown
          Expanded(
            flex: 3, // Increased from 2 to 3 to give more space
            child: DropdownButtonFormField<String>(
              value: _ingredients[index].unit,
              decoration: InputDecoration(
                labelText: 'Satuan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              isExpanded: true, // Prevents overflow
              items: _units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(
                    unit,
                    overflow: TextOverflow.ellipsis, // Handle long text
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _ingredients[index].unit = newValue ?? 'pcs';
                });
              },
            ),
          ),

          SizedBox(width: 8),

          // Ingredient Name Input
          Expanded(
            flex: 4,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Nama Bahan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
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
              onPressed: () => _removeIngredient(index),
              icon: Icon(Icons.remove_circle, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeTypeSelector() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Jenis Resep',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _selectedRecipeType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
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
        ],
      ),
    );
  }

  Icon _getRecipeTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icon(Icons.free_breakfast, color: Colors.orange, size: 20);
      case 'lunch':
        return Icon(Icons.lunch_dining, color: Colors.green, size: 20);
      case 'dinner':
        return Icon(Icons.dinner_dining, color: Colors.blue, size: 20);
      case 'snack':
        return Icon(Icons.cookie, color: Colors.purple, size: 20);
      case 'dessert':
        return Icon(Icons.cake, color: Colors.pink, size: 20);
      case 'appetizer':
        return Icon(Icons.tapas, color: Colors.red, size: 20);
      case 'beverage':
        return Icon(Icons.local_drink, color: Colors.cyan, size: 20);
      case 'salad':
        return Icon(Icons.eco, color: Colors.lightGreen, size: 20);
      default:
        return Icon(Icons.restaurant, color: Colors.grey, size: 20);
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRecipeTypeSelector(),
          SizedBox(height: 16),
          _buildIngredientHeader(),
          SizedBox(height: 16),
          ...List.generate(_ingredients.length, _buildIngredientItem),
          SizedBox(height: 16),
          _buildGenerateButton(),
          if (_hasValidIngredients()) _buildPreviewBox(),
        ],
      ),
    );
  }

  Widget _buildIngredientHeader() {
    return Row(
      children: [
        Icon(Icons.list_alt, color: Colors.orange),
        SizedBox(width: 8),
        Text('Daftar Bahan-bahan', style: _sectionTitleStyle()),
        Spacer(),
        IconButton(
          onPressed: _addIngredient,
          icon: Icon(Icons.add_circle, color: Colors.orange),
          tooltip: 'Tambah Bahan',
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _generateRecipe,
      style: _buttonStyle(Colors.orange),
      child: _isLoading
          ? _loadingIndicator('Generating...')
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome),
          SizedBox(width: 8),
          Text('Generate ${_recipeTypeLabels[_selectedRecipeType]} Recipe'),
        ],
      ),
    );
  }

  Widget _buildPreviewBox() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview:', style: _previewTitleStyle()),
          SizedBox(height: 4),
          Text('Type: ${_recipeTypeLabels[_selectedRecipeType]}', style: _previewContentStyle()),
          Text('Ingredients: ${_getIngredientsText()}', style: _previewContentStyle()),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultHeader(),
          SizedBox(height: 12),
          _isLoading ? _loadingMessage() : _buildRecipeContent(),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        Icon(Icons.receipt_long, color: Colors.orange),
        SizedBox(width: 8),
        Text('Generated Recipe', style: _sectionTitleStyle()),
        Spacer(),
        if (_generatedRecipe.isNotEmpty && !_isLoading)
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveRecipe,
            icon: _isSaving
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
            )
                : Icon(Icons.save, size: 16),
            label: Text(_isSaving ? 'Saving...' : 'Save'),
            style: _buttonStyle(Colors.green, fontSize: 12, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
      ],
    );
  }

  Widget _loadingIndicator(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        ),
        SizedBox(width: 12),
        Text(text),
      ],
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

  Widget _buildRecipeContent() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        child: Text(
          _generatedRecipe,
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
        ),
      ),
    );
  }

// Reusable styles and decorations
  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ],
  );

  TextStyle _sectionTitleStyle() => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.grey[800],
  );

  TextStyle _previewTitleStyle() => TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue[800],
    fontSize: 12,
  );

  TextStyle _previewContentStyle() => TextStyle(
    color: Colors.blue[700],
    fontSize: 12,
  );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Recipe Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputSection(),
          SizedBox(height: 20),
          if (_generatedRecipe.isNotEmpty || _isLoading) _buildResultCard(),
        ],
      ),
      ),
    );
  }
}