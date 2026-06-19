import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.image,
    required this.text,
    this.trailing,
    required this.ontap,
    this.imageColor,
    this.subtitle,
  });
  final String image;
  final String text;
  final String? trailing;
  final Function()? ontap;
  final Color? imageColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: AppColor.lightOrangeColor,
      onTap: ontap,
      leading: Image.asset(
        image,
        color: imageColor,
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.grey),
            )
          : null,
      trailing: trailing != null ? Image.asset(trailing!) : null,
    );
  }
}
