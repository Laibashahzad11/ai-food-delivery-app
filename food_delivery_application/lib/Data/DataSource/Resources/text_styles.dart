import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle largeSen(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 30.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? Colors.white,
      fontFamily: "Sen",
      fontWeight: fontWeight ?? FontWeight.w700,
    );
  }

  static TextStyle medSen(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 16.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? Colors.white,
      fontFamily: "Sen",
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }

  static TextStyle semiMedSen(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 14.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? Colors.white,
      fontFamily: "Sen",
      fontWeight: fontWeight ?? FontWeight.w700,
    );
  }

  static TextStyle ragularSen(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 13.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? const Color(0xff32343E),
      fontFamily: "Sen",
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  static TextStyle urbanistLar(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 20.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? Colors.black,
      fontFamily: "Urbanist",
      fontWeight: fontWeight ?? FontWeight.w600,
    );
  }

  static TextStyle selectedAndUnseletedStyle(BuildContext context,
      {double? fontSize,
      Color? color,
      FontWeight? fontWeight,
      double? letterSpacing}) {
    return TextStyle(
      fontSize: (fontSize ?? 10.0),
      letterSpacing: letterSpacing ?? 0,
      color: color ?? Colors.blue,
      fontFamily: "Urbanist",
      fontWeight: fontWeight ?? FontWeight.w500,
    );
  }
}
