import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/my_list_tile.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/widgets/personal_info_header.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Info'),
      ),
      body: Column(
        children: [
          PersonalInfoHeader(
            user: widget.user,
          ),
          Column(
            children: [
              MyListTile(
                imageColor: AppColor.orangeColor,
                ontap: () {},
                image: 'assets/images/User.png',
                text: 'FULL NAME',
                subtitle: widget.user.name,
              ),
              MyListTile(
                imageColor: AppColor.blueColor,
                ontap: () {},
                image: 'assets/images/mail.png',
                text: 'EMAIL',
                subtitle: widget.user.email,
              ),
              MyListTile(
                imageColor: AppColor.blueColor,
                ontap: () {},
                image: 'assets/images/Call.png',
                text: 'PHONE',
                subtitle: widget.user.phoneNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
