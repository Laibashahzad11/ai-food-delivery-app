import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/login.dart';

class UserOrChef extends StatefulWidget {
  const UserOrChef({super.key});

  @override
  State<UserOrChef> createState() => _UserOrChefState();
}

class _UserOrChefState extends State<UserOrChef> {
  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your Role",
                  style: TextStyles.largeSen(context).copyWith(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Buttons(
                    isloading: false,
                    width: width,
                    height: height,
                    title: "USER",
                    ontap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(role: 'User'),
                        ),
                      );
                    }),
                const SizedBox(
                  height: 40,
                ),
                Buttons(
                    isloading: false,
                    width: width,
                    height: height,
                    title: "CHEF",
                    ontap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(role: 'Chef'),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
