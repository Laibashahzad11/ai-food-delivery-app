import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/chef_text_field.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/request_orders.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isloading = false;
  XFile? selectedImage;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().appUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: screenHeight(context) * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      selectedImage != null
                          ? CircleAvatar(
                              radius: 70,
                              backgroundImage: FileImage(
                                File(selectedImage!.path),
                              ),
                            )
                          : CircleAvatar(
                              radius: 70,
                              backgroundColor: AppColor.lightOrangeColor,
                              child: user!.userImage != null
                                  ? Container(
                                      height: screenHeight(context),
                                      width: screenWidth(context),
                                      // margin: EdgeInsets.all(5),
                                      // padding: EdgeInsets.all(5),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
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
                      if (context.watch<AuthController>().isloading)
                        const Positioned(
                          bottom: 0,
                          top: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.mediumOrangeColor,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final image = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (selectedImage != null) {
                                setState(() {
                                  selectedImage = image;
                                });
                              }

                              // ignore: use_build_context_synchronously
                              await context.read<AuthController>().updateUser(
                                  // ignore: use_build_context_synchronously
                                  user: context.read<AuthController>().appUser!,
                                  image: image);
                              context.mySnackBar(text: 'IMAGE UPLOADED');
                            } catch (e) {}
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                color: AppColor.orangeColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight(context) * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FULL NAME'),
                        ChefTextField(
                          validator: Validate.name,
                          hint: 'Saqlain Kamal',
                          controller: nameController,
                        ),
                        const Text('EMAIL'),
                        ChefTextField(
                          validator: (value) {
                            return Validate.email(value);
                          },
                          hint: 'Hilal@gmail.co',
                          controller: emailController,
                        ),
                        const Text('PHONE'),
                        ChefTextField(
                          validator: Validate.number,
                          hint: '12312-242-223',
                          controller: phoneController,
                        ),
                        const Text(
                          'BIO',
                        ),
                        ChefTextField(
                          validator: (value) {
                            return Validate.name(value);
                          },
                          controller: bioController,
                          hint: 'I Love Fast Food',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  NormalButton(
                      isloading: isloading,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isloading = true;
                          });
                          try {
                            final user = UserModel(
                                id: context.read<AuthController>().appUser!.id,
                                name: nameController.text,
                                email: emailController.text,
                                role: context
                                    .read<AuthController>()
                                    .appUser!
                                    .role,
                                phoneNumber: phoneController.text,
                                bio: bioController.text,
                                userImage: '',
                                resturantName: '');

                            await context
                                .read<AuthController>()
                                .updateUser(user: user, image: selectedImage);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColor.orangeColor,
                                content: Text("Personal Info Updated"),
                              ),
                            );
                            setState(() {
                              isloading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isloading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    "There is an issue please check your network connection and try again"),
                              ),
                            );
                          }
                        }
                      },
                      text: 'SAVE')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
