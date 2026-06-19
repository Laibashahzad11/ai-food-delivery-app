import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/strings.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/home.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/user_dashboard.dart';
import 'package:provider/provider.dart';

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({
    super.key,
    required this.role,
    this.user,
  });
  final String role;
  final UserModel? user;

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.30,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(90)),
                  child: Image.asset('assets/images/location.png'),
                ),
                Gap.verticalSpace(height * 0.1),
                Buttons(
                  isloading: isloading,
                  widgets: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 252, 153, 90)),
                    height: height * 0.1,
                    width: width * 0.1,
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                  ),
                  width: width,
                  height: height,
                  title: AppStrings.accessLocation,
                  ontap: () async {
                    try {
                      setState(() {
                        isloading = true;
                      });
                      await context
                          .read<GetPermissionLocation>()
                          .getPermission();
                      final lat = context
                          .read<GetPermissionLocation>()
                          .currentPosition!
                          .latitude;
                      final lon = context
                          .read<GetPermissionLocation>()
                          .currentPosition!
                          .longitude;
                      widget.user!.lat = lat.toString();
                      widget.user!.lon = lon.toString();
                      context
                          .read<AuthController>()
                          .updateUser(user: widget.user!);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => widget.role == 'User'
                              ? const UserDashboard()
                              : const Home(),
                        ),
                      );
                      setState(() {
                        isloading = false;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.deepOrange,
                        content: Text(
                          e.toString(),
                        ),
                      ));
                      setState(() {
                        isloading = false;
                      });
                    }
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(builder: (context) => const Home()),
                    // );
                  },
                ),
                Gap.verticalSpace(height * 0.07),
                Text(
                  AppStrings.foodWillAccess,
                  textAlign: TextAlign.center,
                  style: TextStyles.medSen(context)
                      .copyWith(color: const Color(0xff7E8A97), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
