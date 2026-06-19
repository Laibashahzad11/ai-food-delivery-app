import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/my_cart.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/profile.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:provider/provider.dart';

class UserListTile extends StatefulWidget {
  const UserListTile({
    super.key,
  });

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  @override
  void initState() {
    print('object');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      print('Widget Post Frame Callback');
      final appUser = context.read<AuthController>().appUser;
      if (appUser != null) {
        await context
            .read<ProductController>()
            .getCartCount(uid: appUser.id);
      }
      await context.read<GetPermissionLocation>().getPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profile(),
                ),
              );
            },
            child: Image.asset('assets/images/Menu.png')),
        title: const Text(
          'Location',
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
        subtitle: Consumer<GetPermissionLocation>(builder: (context, value, _) {
          return Text(
            value.currentDistrict ?? 'Fetching location...',
            style: const TextStyle(fontSize: 13),
          );
        }),
        trailing: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyCart(),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: 25,
            child: Consumer<ProductController>(builder: (context, value, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/bag.png',
                    color: Colors.white,
                  ),
                  Positioned(
                    top: -20,
                    right: -15,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColor.orangeColor,
                      ),
                      child: Center(
                        child: Text(
                          value.myCartLength.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
