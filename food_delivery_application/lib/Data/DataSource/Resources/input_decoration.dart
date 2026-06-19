import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';

class Data {
  InputDecoration decoration(BuildContext context, String? hint, Widget? icon) {
    return InputDecoration(
      filled: true,
      hintStyle: TextStyles.ragularSen(context).copyWith(
        fontSize: 13,
        color: const Color(0xffA0A5BA),
      ),
      hintText: hint,
      suffixIcon: icon,
      fillColor: const Color(0xffF0F5FA),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xffF0F5FA)),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.orangeColor),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }
}
