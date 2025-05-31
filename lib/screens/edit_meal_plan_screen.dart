import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fp_recipe/models/meal_plan_model.dart';
import 'package:fp_recipe/models/recipe_model.dart';
import 'package:fp_recipe/services/meal_plan_service.dart';

class EditMealPlanScreen extends StatefulWidget {
  const EditMealPlanScreen({super.key});

  @override
  State<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends State<EditMealPlanScreen> {
  final MealPlanService _mealPlanService = MealPlanService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  MealPlan? _currentMealPlan;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load the meal plan in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the meal plan from arguments if it exists
    final mealPlan = ModalRoute.of(context)?.settings.arguments as MealPlan?;

    if (mealPlan != null && _currentMealPlan == null) {
      // Editing an existing meal plan
      setState(() {
        _currentMealPlan = mealPlan;
        _selectedDate = mealPlan.date;
        _titleController.text = mealPlan.title;
        _descriptionController.text = mealPlan.description;
      });
    } else if (_currentMealPlan == null) {
      // Creating a new meal plan
      _loadMealPlan();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMealPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mealPlan = await _mealPlanService.getMealPlanForDate(_selectedDate);

      setState(() {
        _currentMealPlan = mealPlan;
        _titleController.text = mealPlan?.title ?? '';
        _descriptionController.text = mealPlan?.description ?? '';
      });
    } catch (e) {
      _showErrorSnackBar('Error loading meal plan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMealPlan();
    }
  }

  void _showAddRecipeDialog(MealTime mealTime) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Recipe to ${_getMealTimeTitle(mealTime)}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _mealPlanService.getDummyRecipes().length,
              itemBuilder: (context, index) {
                final recipe = _mealPlanService.getDummyRecipes()[index];
                return ListTile(
                  title: Text(recipe.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.description),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children:
                            recipe.types
                                .map(
                                  (type) => Chip(
                                    label: Text(
                                      type,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.pop(context);
                    _addRecipeToMealPlan(mealTime, recipe);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addRecipeToMealPlan(MealTime mealTime, Recipe recipe) {
    if (_currentMealPlan == null) return;

    setState(() {
      _currentMealPlan = _mealPlanService.addRecipeToMealPlan(
        _currentMealPlan!,
        mealTime,
        recipe,
      );
    });

    _showSuccessSnackBar(
      'Added ${recipe.name} to ${_getMealTimeTitle(mealTime)}',
    );
  }

  void _removeRecipeFromMealPlan(MealTime mealTime, Recipe recipe) {
    if (_currentMealPlan == null) return;

    setState(() {
      _currentMealPlan = _mealPlanService.removeRecipeFromMealPlan(
        _currentMealPlan!,
        mealTime,
        recipe.id,
      );
    });

    _showSuccessSnackBar(
      'Removed ${recipe.name} from ${_getMealTimeTitle(mealTime)}',
    );
  }

  Future<void> _saveMealPlan() async {
    if (_currentMealPlan == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Create updated meal plan with current title and description
      final updatedMealPlan = MealPlan(
        id: _currentMealPlan!.id,
        date: _currentMealPlan!.date,
        title: _titleController.text,
        description: _descriptionController.text,
        meals: _currentMealPlan!.meals,
        userId: _currentMealPlan!.userId,
      );

      final success = await _mealPlanService.saveMealPlan(updatedMealPlan);

      if (success) {
        _showSuccessSnackBar('Meal plan saved successfully');

        // Return true to indicate success
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showErrorSnackBar('Failed to save meal plan');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving meal plan: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _getMealTimeTitle(MealTime mealTime) {
    return mealTime.toString().split('.').last[0].toUpperCase() +
        mealTime.toString().split('.').last.substring(1);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildMealTimeSection(MealTime mealTime) {
    final String mealTimeTitle = _getMealTimeTitle(mealTime);
    final List<Recipe> recipes = _currentMealPlan?.meals[mealTime] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealTimeTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddRecipeDialog(mealTime),
            ),
          ],
        ),
        if (recipes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No recipes added yet'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${index + 1}. ${recipe.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.description),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children:
                            recipe.types
                                .map(
                                  (type) => Chip(
                                    label: Text(
                                      type,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed:
                        () => _removeRecipeFromMealPlan(mealTime, recipe),
                  ),
                ),
              );
            },
          ),
        const Divider(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final isNewMealPlan = _currentMealPlan?.id == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewMealPlan ? 'Create Meal Plan' : 'Edit Meal Plan'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed:
                              isNewMealPlan ? () => _selectDate(context) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title and description fields
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Meal time sections
                    _buildMealTimeSection(MealTime.morning),
                    _buildMealTimeSection(MealTime.afternoon),
                    _buildMealTimeSection(MealTime.night),

                    // Save button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveMealPlan,
                        icon:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: const Text('Save Meal Plan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }
}
