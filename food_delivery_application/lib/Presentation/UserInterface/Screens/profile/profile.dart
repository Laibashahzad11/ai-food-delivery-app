import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/my_list_tile.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/user_or_chef.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/my_cart.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/my_orders.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/edit_profile.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/my_addresses.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/personal_info.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/widgets/personal_info_header.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfile(),
                  ),
                );
              },
              child: const Text(
                'EDIT',
                style: TextStyle(color: AppColor.orangeColor),
              ))
        ],
      ),
      body: Column(
        children: [
          PersonalInfoHeader(
            user: context.read<AuthController>().appUser!,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: screenHeight(context) * 0.16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyListTile(
                    imageColor: AppColor.orangeColor,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInfo(
                            user: context.read<AuthController>().appUser!,
                          ),
                        ),
                      );
                    },
                    image: 'assets/images/User.png',
                    text: 'Personal Info',
                    trailing: 'assets/images/Vector.png'),
                MyListTile(
                    imageColor: AppColor.purpleColor,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyAddresses(),
                        ),
                      );
                    },
                    image: 'assets/images/Home.png',
                    text: 'Addresses',
                    trailing: 'assets/images/Vector.png'),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight(context) * 0.31,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyListTile(
                    imageColor: AppColor.blueColor,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCart(),
                        ),
                      );
                    },
                    image: 'assets/images/credit-card.png',
                    text: 'Cart',
                    trailing: 'assets/images/Vector.png'),
                MyListTile(
                    imageColor: AppColor.purpleColor,
                    ontap: () {},
                    image: 'assets/images/heart.png',
                    text: 'Favorite',
                    trailing: 'assets/images/Vector.png'),
                // MyListTile(
                //     ontap: () {},
                //     image: 'assets/images/bell.png',
                //     text: 'Notifications',
                //     trailing: 'assets/images/Vector.png'),
                MyListTile(
                    imageColor: AppColor.blueColor,
                    ontap: () {},
                    image: 'assets/images/credit-card.png',
                    text: 'Payment Method',
                    trailing: 'assets/images/Vector.png'),
                MyListTile(
                    imageColor: AppColor.orangeColor,
                    ontap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyOrders()));
                    },
                    image: 'assets/images/credit-card.png',
                    text: 'My Orders',
                    trailing: 'assets/images/Vector.png'),
                // MyListTile(
                //     imageColor: AppColor.blueColor,
                //     ontap: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => const GoogleMapUI()));
                //     },
                //     image: 'assets/images/credit-card.png',
                //     text: 'Map',
                //     trailing: 'assets/images/Vector.png'),
              ],
            ),
          ),
          // SizedBox(
          //   height: screenHeight(context) * 0.23,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       MyListTile(
          //           ontap: () {},
          //           image: 'assets/images/credit-card.png',
          //           text: 'FAQs',
          //           trailing: 'assets/images/Vector.png'),
          //       MyListTile(
          //           ontap: () {},
          //           image: 'assets/images/FAQ.png',
          //           text: 'User Reviews',
          //           trailing: 'assets/images/Vector.png'),
          //       MyListTile(
          //           ontap: () {},
          //           image: 'assets/images/settings.png',
          //           text: 'Settings',
          //           trailing: 'assets/images/Vector.png'),
          //     ],
          //   ),
          // ),
          MyListTile(
              imageColor: AppColor.orangeColor,
              ontap: () async {
                try {
                  await context.read<AuthController>().signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserOrChef(),
                    ),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.deepOrange,
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              image: 'assets/images/Logout.png',
              text: 'Log Out',
              trailing: 'assets/images/Vector.png'),
        ],
      ),
    );
  }
}
