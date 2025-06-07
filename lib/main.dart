import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:fp_recipe/screens/edit_meal_plan_screen.dart';
import 'package:fp_recipe/screens/login.dart';
import 'package:fp_recipe/screens/main_layout.dart';
import 'package:fp_recipe/screens/ingredient_list.dart';
import 'package:fp_recipe/screens/meal_plans_list_screen.dart';
import 'package:fp_recipe/screens/recipe_detail.dart';
import 'package:fp_recipe/screens/recipe_list.dart';
import 'package:fp_recipe/screens/shopping_list.dart';
import 'package:fp_recipe/screens/register.dart';
import 'package:fp_recipe/services/notification_service.dart';
import 'package:fp_recipe/widgets/splash_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null, // no custom icon for now
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Channel for basic notifications',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        channelDescription: 'Channel for scheduled notifications',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
    debug: true,
  );

  // Initialize FCM after Awesome Notifications
  await AwesomeNotificationsFcm().initialize(
    onFcmSilentDataHandle: NotificationService.onFcmSilentDataHandle,
    onFcmTokenHandle: NotificationService.onFcmTokenHandle,
    onNativeTokenHandle: NotificationService.onNativeTokenHandle,
    licenseKeys: null,
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF03A9F4), // Light blue color for splash
        secondaryHeaderColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: 'login',
      routes: {
        'home': (context) => const SplashScreenWidget(child: MainLayout()),
        'login': (context) => const SplashScreenWidget(child: LoginScreen()),
        'register':
            (context) => const SplashScreenWidget(child: RegisterScreen()),
        'ingredients':
            (context) =>
                const SplashScreenWidget(child: IngredientListScreen()),
        'shopping':
            (context) => const SplashScreenWidget(child: ShoppingListScreen()),
        'mealPlan':
            (context) => const SplashScreenWidget(child: MealPlansListScreen()),
        'edit_meal_plan':
            (context) => const SplashScreenWidget(child: EditMealPlanScreen()),
        'recipe':
            (context) => const SplashScreenWidget(child: RecipeListScreen()),
        'recipe_detail':
            (context) => const SplashScreenWidget(child: RecipeDetailScreen()),
      },
    );
  }
}
