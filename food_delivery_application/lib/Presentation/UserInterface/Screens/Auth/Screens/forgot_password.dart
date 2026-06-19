import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/assets.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/strings.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({
    super.key,
  });

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: const Color(0xff121223),
            image: DecorationImage(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              image: AssetImage(
                Images.bg,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          height: height * 0.12,
                          width: width * 0.12,
                          child: const Icon(Icons.arrow_back_ios_outlined)),
                    ),
                  ),
                ),
                Text(
                  AppStrings.forgot,
                  style: TextStyles.largeSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                Text(
                  AppStrings.existingAccount,
                  style: TextStyles.medSen(context),
                ),
                Gap.verticalSpace(height * 0.07),
                const BottomSheet()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomSheet extends StatefulWidget {
  const BottomSheet({super.key});

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Form(
      key: formKey,
      child: Expanded(
        child: Container(
          height: height * 0.65,
          width: width,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppStrings.email,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: TextFormField(
                    validator: Validate.email,
                    decoration: Data()
                        .decoration(context, AppStrings.emailFormat, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.02),
                Buttons(
                  isloading: false,
                  width: width,
                  height: height,
                  title: AppStrings.sendCode,
                  widgets: null,
                  ontap: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email.text);
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error sending password reset email: $e');
                      // Handle the specific error
                      if (e is PlatformException &&
                          e.code == 'firebase_auth/channel-error') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text(
                                'Failed to establish connection with Firebase Authentication service. Please check your network connection and try again.'),
                          ),
                        );
                      } else {
                        // Handle other types of errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text(
                                'Failed to send password reset email. Please try again later.'),
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
