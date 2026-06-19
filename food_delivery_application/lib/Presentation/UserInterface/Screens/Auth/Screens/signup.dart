import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/assets.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/strings.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/location_access.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    this.role,
    super.key,
  });
  final String? role;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Text(
                  AppStrings.signUp,
                  style: TextStyles.largeSen(context),
                ),
                Text(
                  AppStrings.getStarted,
                  style: TextStyles.medSen(context),
                ),
                Gap.verticalSpace(height * 0.08),
                BottomSheet(
                  role: widget.role ?? '',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomSheet extends StatefulWidget {
  const BottomSheet({
    super.key,
    required this.role,
  });
  final String role;

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  bool isloading = false;
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final confirmPassword = TextEditingController();
  final resturantName = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Container(
      height: height * 0.8,
      width: width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
        child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.name,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: TextFormField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    validator: Validate.name,
                    controller: name,
                    decoration:
                        Data().decoration(context, AppStrings.rimsha, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.01),
                widget.role == 'User'
                    ? const SizedBox()
                    : Text(
                        AppStrings.resturantName,
                        style: TextStyles.ragularSen(context),
                      ),
                Gap.verticalSpace(height * 0.01),
                widget.role == 'User'
                    ? const SizedBox()
                    : SizedBox(
                        height: height * 0.07,
                        child: TextFormField(
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          validator: Validate.name,
                          controller: resturantName,
                          decoration: Data()
                              .decoration(context, AppStrings.resturant, null),
                        ),
                      ),
                Text(
                  AppStrings.email,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: TextFormField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: email,
                    decoration: Data()
                        .decoration(context, AppStrings.emailFormat, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.01),
                Text(
                  AppStrings.phone,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: IntlPhoneField(
                    initialCountryCode: 'PK',
                    controller: phone,
                    decoration: Data()
                        .decoration(context, AppStrings.phoneFormat, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.01),
                Text(
                  AppStrings.password,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: TextFormField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: password,
                    validator: Validate.password,
                    decoration: Data()
                        .decoration(context, AppStrings.passwordFormat, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.01),
                Text(
                  AppStrings.reTypePassword,
                  style: TextStyles.ragularSen(context),
                ),
                Gap.verticalSpace(height * 0.01),
                SizedBox(
                  height: height * 0.07,
                  child: TextFormField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: confirmPassword,
                    // validator: (value) {
                    //   if (value!=password.) {

                    //   }
                    // },
                    decoration: Data()
                        .decoration(context, AppStrings.passwordFormat, null),
                  ),
                ),
                Gap.verticalSpace(height * 0.03),
                Buttons(
                    isloading: isloading,
                    width: width,
                    height: height,
                    title: AppStrings.signUp,
                    ontap: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isloading = true;
                        });
                        try {
                          final user = UserModel(
                            phoneNumber: phone.text.trim(),
                            bio: 'Fast Food Is Amazing',
                            role: widget.role,
                            email: email.text.trim(),
                            id: "",
                            name: name.text.trim(),
                            resturantName: resturantName.text.trim(),
                          );
                          await context
                              .read<AuthController>()
                              .sighUpWithEmailAndPassword(
                                user,
                                password.text.trim(),
                              );

                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return LocationAccessScreen(
                              user: user,
                              role: widget.role,
                            );
                          }));
                          setState(() {
                            isloading = false;
                          });
                        } catch (e) {
                          setState(() {
                            isloading = false;
                          });
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text(
                              e.toString(),
                            ),
                          ));
                        }
                      }
                    }),
              ],
            )),
      ),
    );
  }
}
