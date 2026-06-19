import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/ui_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/add_new_item.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/dasboard.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/menu.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/notification.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/personal.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> pages = [
    const Dashboard(),
    const Menu(),
    const NotificationScreen(),
    const PersonalScreen(),
  ];

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 1,
        backgroundColor: Colors.white,
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(width: 1.1, color: Colors.deepOrange),
                borderRadius: BorderRadius.circular(50)),
            child: const Icon(
              Icons.add,
              color: Colors.deepOrange,
            )),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewItem(),
            ),
          );
        },
      ),
      // appBar: AppBar(
      //   systemOverlayStyle: const SystemUiOverlayStyle(
      //     statusBarColor: Colors.green, // <-- SEE HERE
      //     statusBarIconBrightness:
      //         Brightness.dark, //<-- For Android SEE HERE (dark icons)
      //     statusBarBrightness:
      //         Brightness.light, //<-- For iOS SEE HERE (dark icons)
      //   ),
      // ),
      bottomNavigationBar: const NavBar(),
      body: Consumer<UIcontroller>(
        builder: (context, value, child) {
          return WillPopScope(
              onWillPop: () async {
                log('this is executing');
                if (value.currentIndex != 0) {
                  // If not on the dashboard screen, navigate to the dashboard

                  value.changeindex(0);

                  return false; // Prevent default back button behavior
                } else {
                  // If on the dashboard screen, allow app to close
                  return true; // Allow default back button behavior
                }
              },
              child: pages[value.currentIndex]);
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.deepOrange,
      //   shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(50),
      //       side: const BorderSide(width: 1, color: Colors.deepOrange)),
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UIcontroller>(
      builder: (context, value, child) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColor.orangeColor,
          onTap: (index) {
            print(index);
            value.changeindex(index);
          },
          currentIndex: value.currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: '',
            ),
            // BottomNavigationBarItem(
            //   icon: Container(
            //       padding: const EdgeInsets.all(12),
            //       decoration: BoxDecoration(
            //           color: Colors.orange.shade50.withOpacity(0.5),
            //           border: Border.all(width: 1.1, color: Colors.deepOrange),
            //           borderRadius: BorderRadius.circular(50)),
            //       child: const Icon(
            //         Icons.add,
            //         color: Colors.deepOrange,
            //       )),
            //   label: '',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_outlined),
              label: '',
            ),
          ],
        );
      },
    );
  }
}
