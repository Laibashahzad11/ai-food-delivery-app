import 'package:flutter/material.dart';

import '../../../Data/DataSource/Resources/color.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColor.lightGreyColor,
      child: InkWell(
          onTap: () {}, child: Image.asset("assets/images/back_Arrow.png")),
    );
  }
}
