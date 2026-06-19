import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/my_list_tile.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/reviews.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/user_or_chef.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/personal_info.dart';
import 'package:provider/provider.dart';

class ProfileItems extends StatelessWidget {
  const ProfileItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight(context) * 0.52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: screenHeight(context) * 0.17,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyListTile(
                      ontap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonalInfo(
                                      user: context
                                          .read<AuthController>()
                                          .appUser!,
                                    )));
                      },
                      image: 'assets/images/User.png',
                      text: 'Personal Info',
                      trailing: 'assets/images/Vector.png'),
                  MyListTile(
                      ontap: () {},
                      image: 'assets/images/settings.png',
                      text: 'Settings',
                      trailing: 'assets/images/Vector.png'),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight(context) * 0.16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyListTile(
                      ontap: () {},
                      image: 'assets/images/withdrawal 1.png',
                      text: 'Withdrawal History',
                      trailing: 'assets/images/Vector.png'),
                  ListTile(
                    onTap: () {},
                    leading: Image.asset(
                      'assets/images/withdrawal 1.png',
                    ),
                    title: const Text(
                      'Number of Orders',
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: const Text(
                      '29k',
                      style: TextStyle(
                          color: Color(0xff9C9BA6),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight(context) * 0.16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyListTile(
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReviewScreen(),
                          ),
                        );
                      },
                      image: 'assets/images/FAQ.png',
                      text: 'User Reviews',
                      trailing: 'assets/images/Vector.png'),
                  MyListTile(
                      ontap: () async {
                        try {
                          await context.read<AuthController>().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserOrChef(),
                            ),
                          );
                        } catch (e) {
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
                      trailing: 'assets/images/Vector.png')
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
