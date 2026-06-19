import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/profile_container.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/profile_items.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  XFile? selectedImage;
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().appUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 17),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                selectedImage != null
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: FileImage(
                          File(selectedImage!.path),
                        ),
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: user!.userImage != null
                            ? Container(
                                height: screenHeight(context),
                                width: screenWidth(context),
                                // margin: EdgeInsets.all(5),
                                // padding: EdgeInsets.all(5),
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: user.userImage!,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                    color: AppColor.orangeColor,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ))
                            : Container(),
                      ),
                Positioned(
                  right: 0,
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      setState(() {
                        selectedImage = image;
                      });
                      // ignore: use_build_context_synchronously
                      await context.read<AuthController>().updateUser(
                          // ignore: use_build_context_synchronously
                          user: context.read<AuthController>().appUser!,
                          image: image);
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                            color: AppColor.orangeColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: AppColor.mediumOrangeColor,
      ),
      body: const Column(
        children: [
          ProfileContainer(),
          ProfileItems(),
        ],
      ),
    );
  }
}
