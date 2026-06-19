import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Splash/splash.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.senTextTheme(
        Theme.of(context).textTheme,
      )),
      home: const Splash(),
    );
  }
}
