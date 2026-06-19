import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';

class PersonalInfoHeader extends StatelessWidget {
  const PersonalInfoHeader({
    required this.user,
    super.key,
  });
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    // final user = context.read<AuthController>().appUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppColor.lightOrangeColor,
            // backgroundImage:
            //     user!.userImage != null ? NetworkImage(user.userImage!) : null,
            child: user.userImage != null && user.userImage!.isNotEmpty
                ? Container(
                    height: screenHeight(context),
                    width: screenWidth(context),
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
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
                : Image.asset('assets/images/default_chef.png', fit: BoxFit.cover),
          ),
          SizedBox(
            width: screenWidth(context) * 0.08,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                user.bio,
                style: const TextStyle(color: Color(0xffA0A5BA), fontSize: 13),
              )
            ],
          ),
        ],
      ),
    );
  }
}
