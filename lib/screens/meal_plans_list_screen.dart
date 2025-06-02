import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fp_recipe/models/meal_plan_model.dart';
import 'package:fp_recipe/services/meal_plan_service.dart';

class MealPlansListScreen extends StatefulWidget {
  const MealPlansListScreen({super.key});

  @override
  State<MealPlansListScreen> createState() => _MealPlansListScreenState();
}

class _MealPlansListScreenState extends State<MealPlansListScreen>
    with SingleTickerProviderStateMixin {
  final MealPlanService _mealPlanService = MealPlanService();
  List<MealPlan> _mealPlans = [];
  bool _isLoading = true;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController!.forward();
    _loadMealPlans();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadMealPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mealPlans = await _mealPlanService.getAllMealPlans();
      setState(() {
        _mealPlans = mealPlans;
      });
      if (_mealPlans.isNotEmpty) {
        _animationController?.forward(from: 0.0);
      } else {
        _animationController?.reset();
      }
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d,y');

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
                      // Back/Home button
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
                      const SizedBox(width: 8),

                      // Title and subtitle - Flexible, but don't force text ellipsis
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "My Meal Plans",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                            const Text(
                              "Plan your meals for the week ahead",
                              style: TextStyle(
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

                // Search bar (placeholder)
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
                              hintText: "Search meal plans...",
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
                                "Your Plans",
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
                                      Icons.filter_list,
                                      color: Color(0xFF2A9D8F),
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Filter",
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
                          child:
                              _isLoading
                                  ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF2A9D8F),
                                      ),
                                    ),
                                  )
                                  : RefreshIndicator(
                                    color: const Color(0xFF2A9D8F),
                                    onRefresh: _loadMealPlans,
                                    child:
                                        _mealPlans.isEmpty
                                            ? _buildEmptyState()
                                            : ListView.builder(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    20,
                                                    16,
                                                    20,
                                                    20,
                                                  ),
                                              itemCount: _mealPlans.length,
                                              itemBuilder: (context, index) {
                                                final mealPlan =
                                                    _mealPlans[index];
                                                return _buildMealPlanCard(
                                                  mealPlan,
                                                  index,
                                                  _mealPlans.length,
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
      // The floating action button remains for adding new plans
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditMealPlan(context),
        backgroundColor: const Color(0xFF2A9D8F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMealPlanCard(MealPlan mealPlan, int index, int totalPlans) {
    Animation<double> animation;
    if (_animationController != null) {
      animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Interval(
            index / math.max(1, totalPlans),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      );
    } else {
      animation = const AlwaysStoppedAnimation(1.0);
    }

    final dateFormat = DateFormat('MMMM d,y');

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
          color: Color.fromARGB(255, 255, 255, 255),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _navigateToEditMealPlan(context, mealPlan: mealPlan),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dateFormat.format(mealPlan.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2A9D8F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed:
                                () => _navigateToEditMealPlan(
                                  context,
                                  mealPlan: mealPlan,
                                ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _showDeleteConfirmation(mealPlan),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
                      fontSize: 18,
                      color: Color(0xFF2A3136),
                    ),
                  ),
                  if (mealPlan.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      mealPlan.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12, thickness: 1),
                  _buildMealTimePreview(
                    'Morning',
                    _getMealTimeRecipes(mealPlan, MealTime.morning),
                  ),
                  _buildMealTimePreview(
                    'Afternoon',
                    _getMealTimeRecipes(mealPlan, MealTime.afternoon),
                  ),
                  _buildMealTimePreview(
                    'Night',
                    _getMealTimeRecipes(mealPlan, MealTime.night),
                  ),
                ],
              ),
            ),
          ),
        ),
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
            width: 90,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  Icons.calendar_month,
                  size: 70,
                  color: Color(0xFF2A9D8F),
                ),
              ),
              const Text(
                "No Meal Plans Yet",
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
                  "Start planning your delicious meals for the week ahead!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToEditMealPlan(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Meal Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MealPlan mealPlan) {
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Delete Meal Plan?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3136),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete this meal plan for ${DateFormat('MMMM d,y').format(mealPlan.date)}? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
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
                            await _deleteMealPlan(mealPlan.id!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
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

  Future<void> _deleteMealPlan(String mealPlanId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _mealPlanService.deleteMealPlan(mealPlanId);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal plan deleted successfully'),
              backgroundColor: Color(0xFF2A9D8F),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
}
