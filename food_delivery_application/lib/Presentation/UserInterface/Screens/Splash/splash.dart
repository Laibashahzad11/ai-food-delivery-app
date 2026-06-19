import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/home.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Onboarding/onboarding.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/user_dashboard.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Start loading immediately
    loadData();
  }

  Future<void> loadData() async {
    try {
      // 1. Minimum logo visibility time (3 seconds)
      final minDelay = Future.delayed(const Duration(seconds: 3));

      // 2. Initial parallel data loading
      final loadingTasks = Future.wait([
        context.read<AuthController>().checkCurrentUser(context),
        context.read<ProductController>().getProducts(),
        context.read<GetPermissionLocation>().getPermission(),
      ]);

      // 3. Ensure we wait for BOTH the delay and the initial tasks
      await Future.wait([minDelay, loadingTasks]);
      
      if (!mounted) return;

      final currentUser = context.read<AuthController>().appUser;

      if (currentUser != null) {
        // Post-login parallel fetches
        await Future.wait([
          context.read<AddressController>().getAdress(uid: currentUser.id),
          context.read<ProductController>().getCartCount(uid: currentUser.id),
          if (context.read<ProductController>().productList.isNotEmpty)
            context.read<AuthController>().getRestaurants(product: context.read<ProductController>().productList),
        ]);

        if (!mounted) return;

        if (currentUser.role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Onboarding()),
        );
      }
    } catch (e) {
      print("Splash Error: $e");
      if (!mounted) return;
      // Minimal delay even on error to avoid flash
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Full-screen background
            Positioned.fill(
              child: Image.asset(
                'assets/images/logobg.png',
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
              ),
            ),

            // Logo perfectly centered
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
