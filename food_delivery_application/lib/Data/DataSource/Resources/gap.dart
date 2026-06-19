import 'package:flutter/cupertino.dart';

class Gap {
  static Widget verticalSpace(double vSpace) {
    return SizedBox(
      height: vSpace,
    );
  }

  static Widget horizontalSpace(double hSpace) {
    return SizedBox(
      width: hSpace,
    );
  }
}
