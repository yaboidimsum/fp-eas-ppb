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
    // No direct loading here, done in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_currentMealPlan == null) {
      // Get the meal plan from arguments if it exists
      final mealPlan = ModalRoute.of(context)?.settings.arguments as MealPlan?;

      if (mealPlan != null) {
        // Editing an existing meal plan
        setState(() {
          _currentMealPlan = mealPlan;
          _selectedDate = mealPlan.date;
          _titleController.text = mealPlan.title;
          _descriptionController.text = mealPlan.description;
        });
      } else {
        // Creating a new meal plan, load for the selected date (today initially)
        _loadMealPlan();
      }
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
      // Trim selectedDate to just the date part (no time) for accurate lookup
      final dateOnly = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final mealPlan = await _mealPlanService.getMealPlanForDate(dateOnly);

      setState(() {
        _currentMealPlan = mealPlan;
        _titleController.text = mealPlan?.title ?? '';
        _descriptionController.text = mealPlan?.description ?? '';
        // If a new plan is being created and no plan exists for today,
        // ensure _currentMealPlan is initialized to a new empty plan
        _currentMealPlan ??= MealPlan(
          id: null, // ID will be generated on save
          date: dateOnly,
          title: '',
          description: '',
          meals: {},
          userId: 'user1', // Replace with actual user ID if needed
        );
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2A9D8F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A3136),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A9D8F),
              ),
            ),
          ),
          child: child!,
        );
      },
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
        return Dialog(
          // Use Dialog for more styling control
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Recipe to ${_getMealTimeTitle(mealTime)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3136),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  height:
                      MediaQuery.of(context).size.height *
                      0.5, // Make dialog content take half screen height
                  child: FutureBuilder<List<Recipe>>(
                    // Assuming getDummyRecipes() is asynchronous
                    future: Future.value(
                      _mealPlanService.getDummyRecipes(),
                    ), // Wrap in Future.value for async behavior
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF2A9D8F),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final recipes = snapshot.data ?? [];
                      if (recipes.isEmpty) {
                        return const Center(
                          child: Text('No recipes available.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return Card(
                            // Wrap ListTile in Card for consistent styling
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 1, // Subtle elevation
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(context);
                                _addRecipeToMealPlan(mealTime, recipe);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2A3136),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recipe.description,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                      maxLines:
                                          2, // Limit description to 2 lines
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6, // Increased spacing for chips
                                      runSpacing: 4,
                                      children:
                                          recipe.types
                                              .map(
                                                (type) => Chip(
                                                  label: Text(
                                                    type,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF2A9D8F),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFF2A9D8F,
                                                  ).withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2A9D8F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
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
    if (_currentMealPlan == null) {
      _showErrorSnackBar('No meal plan data to save.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
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
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A9D8F), // Consistent success color
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent, // Consistent error color
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildMealTimeSection(MealTime mealTime) {
    final String mealTimeTitle = _getMealTimeTitle(mealTime);
    final List<Recipe> recipes = _currentMealPlan?.meals[mealTime] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Spacing between sections
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealTimeTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3136),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF2A9D8F),
                ),
                onPressed: () => _showAddRecipeDialog(mealTime),
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
          const SizedBox(height: 8),
          if (recipes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No recipes added for ${mealTimeTitle.toLowerCase()} yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                  ), // More vertical margin for cards
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A3136),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children:
                              recipe.types
                                  .map(
                                    (type) => Chip(
                                      label: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2A9D8F),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: const Color(
                                        0xFF2A9D8F,
                                      ).withOpacity(0.1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed:
                          () => _removeRecipeFromMealPlan(mealTime, recipe),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                );
              },
            ),
          const Divider(height: 24, color: Colors.black12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final isNewMealPlan = _currentMealPlan?.id == null;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  // Changed to Text, removed Expanded
                                  isNewMealPlan ? 'Create Plan' : 'Edit Plan',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons
                                      .edit_calendar, // Icon for editing/creating plans
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                            Text(
                              dateFormat.format(
                                _selectedDate,
                              ), // Show selected date here
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                letterSpacing: 0.2,
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
                    child:
                        _isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF2A9D8F),
                                ),
                              ),
                            )
                            : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date selector
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Plan Details", // Section title
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2A3136),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF2A9D8F),
                                        ),
                                        onPressed:
                                            isNewMealPlan
                                                ? () => _selectDate(context)
                                                : null,
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2A9D8F,
                                          ).withOpacity(0.1),
                                          padding: const EdgeInsets.all(8),
                                          shape: const CircleBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Title and description fields
                                  TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Plan Title', // More descriptive label
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                      hintText: 'e.g., Weekday Meals',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
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
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF2A3136),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                      labelText: 'Description',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                      hintText:
                                          'e.g., Healthy and quick dinners',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
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
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF2A3136),
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
                                      onPressed:
                                          _isSaving || _isLoading
                                              ? null
                                              : _saveMealPlan, // Disable if loading or saving
                                      icon:
                                          _isSaving
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        Colors.white,
                                                      ), // White spinner
                                                ),
                                              )
                                              : const Icon(
                                                Icons.save,
                                                color: Colors.white,
                                              ), // Icon color
                                      label: Text(
                                        _isSaving
                                            ? 'Saving...'
                                            : 'Save Meal Plan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ), // Text color
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2A9D8F,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ), // Consistent border radius
                                        ),
                                        elevation: 2,
                                        // Disable visual if _isSaving or _isLoading
                                        disabledBackgroundColor: const Color(
                                          0xFF2A9D8F,
                                        ).withOpacity(0.5),
                                        disabledForegroundColor: Colors.white
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
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
}
