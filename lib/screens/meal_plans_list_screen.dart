import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fp_recipe/models/meal_plan_model.dart';
import 'package:fp_recipe/services/meal_plan_service.dart';

class MealPlansListScreen extends StatefulWidget {
  const MealPlansListScreen({super.key});

  @override
  State<MealPlansListScreen> createState() => _MealPlansListScreenState();
}

class _MealPlansListScreenState extends State<MealPlansListScreen> {
  final MealPlanService _mealPlanService = MealPlanService();
  List<MealPlan> _mealPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mealPlans = await _mealPlanService.getAllMealPlans();
      print('Loaded ${mealPlans.length} meal plans');

      // Debug each meal plan
      for (var plan in mealPlans) {
        print(
          'Meal plan: ${plan.id}, Date: ${plan.date}, Title: ${plan.title}',
        );
        print('Morning recipes: ${plan.meals[MealTime.morning]?.length ?? 0}');
        print(
          'Afternoon recipes: ${plan.meals[MealTime.afternoon]?.length ?? 0}',
        );
        print('Night recipes: ${plan.meals[MealTime.night]?.length ?? 0}');
      }

      setState(() {
        _mealPlans = mealPlans;
      });
    } catch (e) {
      print('Error loading meal plans: $e');
      _showErrorSnackBar('Error loading meal plans: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToEditMealPlan(
    BuildContext context, {
    MealPlan? mealPlan,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      'edit_meal_plan',
      arguments: mealPlan,
    );

    if (result == true) {
      _loadMealPlans();
    }
  }

  String _getMealTimeRecipes(MealPlan mealPlan, MealTime mealTime) {
    final recipes = mealPlan.meals[mealTime] ?? [];
    if (recipes.isEmpty) return 'None';

    return recipes.map((recipe) => recipe.name).join(', ');
  }

  void _showDeleteConfirmation(MealPlan mealPlan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Meal Plan'),
            content: Text(
              'Are you sure you want to delete this meal plan for ${DateFormat('MMMM d, yyyy').format(mealPlan.date)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteMealPlan(mealPlan.id!);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteMealPlan(String mealPlanId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _mealPlanService.deleteMealPlan(mealPlanId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal plan deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMealPlans();
      } else {
        _showErrorSnackBar('Failed to delete meal plan');
      }
    } catch (e) {
      print('Error deleting meal plan: $e');
      _showErrorSnackBar('Error deleting meal plan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('My Meal Plans'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadMealPlans,
                child:
                    _mealPlans.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No meal plans yet',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed:
                                    () => _navigateToEditMealPlan(context),
                                child: const Text('Create New Meal Plan'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _mealPlans.length,
                          itemBuilder: (context, index) {
                            final mealPlan = _mealPlans[index];
                            print(
                              'Rendering meal plan: ${mealPlan.id}, ${mealPlan.title}',
                            );

                            // Update the Card widget in the ListView.builder
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap:
                                    () => _navigateToEditMealPlan(
                                      context,
                                      mealPlan: mealPlan,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateFormat.format(mealPlan.date),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                ),
                                                onPressed:
                                                    () =>
                                                        _navigateToEditMealPlan(
                                                          context,
                                                          mealPlan: mealPlan,
                                                        ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    () =>
                                                        _showDeleteConfirmation(
                                                          mealPlan,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        mealPlan.title.isNotEmpty
                                            ? mealPlan.title
                                            : 'Untitled Meal Plan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (mealPlan.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(mealPlan.description),
                                      ],
                                      const SizedBox(height: 12),
                                      const Divider(),
                                      _buildMealTimePreview(
                                        'Morning',
                                        _getMealTimeRecipes(
                                          mealPlan,
                                          MealTime.morning,
                                        ),
                                      ),
                                      _buildMealTimePreview(
                                        'Afternoon',
                                        _getMealTimeRecipes(
                                          mealPlan,
                                          MealTime.afternoon,
                                        ),
                                      ),
                                      _buildMealTimePreview(
                                        'Night',
                                        _getMealTimeRecipes(
                                          mealPlan,
                                          MealTime.night,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditMealPlan(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealTimePreview(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
