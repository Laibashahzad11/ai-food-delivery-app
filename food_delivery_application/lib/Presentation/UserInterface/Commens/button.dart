import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';

class Buttons extends StatelessWidget {
  Buttons({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.ontap,
    required this.isloading,
    this.widgets,
  });

  String title;
  Widget? widgets;
  final double width;
  Function() ontap;
  final double height;
  final bool isloading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height * 0.07,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xffFF7622),
        ),
        onPressed: ontap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isloading
                ? const Center(
                    child: SpinKitCircle(
                      color: Colors.white,
                    ),
                  )
                : Text(
                    title,
                    style: TextStyles.semiMedSen(context),
                  ),
            Gap.horizontalSpace(height * 0.01),
            if (widgets != null) widgets!,
          ],
        ),
      ),
    );
  }
}
