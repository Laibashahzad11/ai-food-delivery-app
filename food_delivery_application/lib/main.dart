import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/message_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/notification_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/ui_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Data/api_service.dart';
import 'package:food_delivery_app_project/Data/DataSource/local_recommendation_engine.dart';
import 'package:food_delivery_app_project/firebase_options.dart';
import 'package:food_delivery_app_project/food_delivery_app.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51PR9ns02ebwj0k9O3Jw0ForJhwaIpzUxTV0HOdwvcLhRju7Xl28Z2mYMpB8hRuIKfMGMEo8bk5WuW17H74MpFC6z00Uj2uHEV5';
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
    
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // --- AI BACKEND AUTO-DISCOVERY & ENGINE ---
  // We run these with a timeout to ensure the app doesn't stay on a black screen if they hang
  try {
    await Future.wait([
      ApiService().initializeDynamicIp(),
      LocalRecommendationEngine().init(),
    ]).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Background Initialization Error: $e');
  }
  // ---------------------------------
  // ---------------------------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UIcontroller()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => GetPermissionLocation()),
        ChangeNotifierProvider(create: (_) => MessageController()),
        ChangeNotifierProvider(create: (_) => ReviewController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: const FoodDeliveryApp(),
    ),
  );
}
