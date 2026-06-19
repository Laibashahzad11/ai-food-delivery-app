import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';

class BorderButton extends StatelessWidget {
  const BorderButton({
    required this.borderColor,
    required this.textColor,
    required this.text,
    required this.value,
    required this.onTap,
    required this.isloading,
    super.key,
  });
  final Color borderColor;
  final Color textColor;
  final double value;
  final String text;
  final void Function()? onTap;
  final bool isloading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: value),
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: borderColor,
            )),
        child: Center(
            child: isloading
                ? const Center(
                    child: SpinKitCircle(
                      size: 30,
                      color: AppColor.orangeColor,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(color: textColor),
                  )),
      ),
    );
  }
}
