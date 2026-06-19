import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/assets.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/strings.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/home.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/forgot_password.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/location_access.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/signup.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/user_dashboard.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.role,
    super.key,
  });
  final String role;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Text(
                  AppStrings.login,
                  style: TextStyles.largeSen(context),
                ),
                Text(
                  AppStrings.existingAccount,
                  style: TextStyles.medSen(context),
                ),
                Gap.verticalSpace(height * 0.138),
                BottomSheet(
                  role: widget.role,
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

  final password = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Container(
      height: height * 0.622,
      width: width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.email,
                style: TextStyles.ragularSen(context),
              ),
              Gap.verticalSpace(height * 0.01),
              SizedBox(
                height: height * 0.07,
                child: TextFormField(
                  controller: email,
                  validator: Validate.email,
                  decoration:
                      Data().decoration(context, AppStrings.emailFormat, null),
                ),
              ),
              Gap.verticalSpace(height * 0.02),
              Text(
                AppStrings.password,
                style: TextStyles.ragularSen(context),
              ),
              Gap.verticalSpace(height * 0.01),
              SizedBox(
                height: height * 0.07,
                child: TextFormField(
                  controller: password,
                  validator: Validate.loginPassword,
                  obscureText: true,
                  decoration: Data().decoration(
                    context,
                    AppStrings.passwordFormat,
                    const Icon(Icons.remove_red_eye),
                  ),
                ),
              ),
              Gap.verticalSpace(height * 0.004),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (value) {},
                      ),
                      Text(
                        AppStrings.remember,
                        style: TextStyles.medSen(context).copyWith(
                            color: const Color(0xff7E8A97), fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ForgotScreen()),
                      );
                    },
                    child: Text(
                      AppStrings.forgot,
                      style: TextStyles.medSen(context).copyWith(
                          color: const Color(0xffFF7622), fontSize: 14),
                    ),
                  )
                ],
              ),
              Gap.verticalSpace(height * 0.01),
              Buttons(
                isloading: isloading,
                width: width,
                height: height,
                title: AppStrings.login,
                widgets: null,
                ontap: () async {
                  try {
                    setState(() {
                      isloading = true;
                    });
                    await context
                        .read<AuthController>()
                        .sighInWithEmailAndPassword(
                            email.text.trim(), password.text.trim());

                    // ignore: use_build_context_synchronously
                    // context.read<ProductController>().getProducts();

                    // ignore: use_build_context_synchronously
                    if (context.read<AuthController>().appUser!.role ==
                        'Chef') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Home();
                          },
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const UserDashboard();
                          },
                        ),
                      );
                    }

                    setState(() {
                      isloading = false;
                    });
                  } catch (e) {
                    setState(() {
                      isloading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.deepOrange,
                      content: Text(
                        e.toString(),
                      ),
                    ));
                  }
                },
              ),
              Gap.verticalSpace(height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.dontAccount,
                      style: TextStyles.medSen(context).copyWith(
                          color: const Color(0xff7E8A97), fontSize: 13)),
                  Gap.horizontalSpace(height * 0.02),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen(
                                  role: widget.role,
                                )),
                      );
                    },
                    child: Text(AppStrings.noUsersignUpFound,
                        style: TextStyles.semiMedSen(context)
                            .copyWith(color: const Color(0xffFF7622))),
                  )
                ],
              ),
              Gap.verticalSpace(height * 0.01),
              Align(
                alignment: Alignment.center,
                child: Text(AppStrings.or,
                    style: TextStyles.medSen(context)
                        .copyWith(color: const Color(0xff7E8A97))),
              ),
              Gap.verticalSpace(height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationAccessScreen(
                              role: widget.role,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(Images.facebook)),
                  GestureDetector(
                      onTap: () {}, child: Image.asset(Images.twitter)),
                  GestureDetector(
                      onTap: () {}, child: Image.asset(Images.apple))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
