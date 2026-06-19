import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NormalButton extends StatelessWidget {
  const NormalButton({
    required this.onTap,
    required this.text,
    required this.isloading,
    this.width,
    this.color,
    super.key,
  });
  final void Function()? onTap;
  final String text;
  final bool isloading;
  final Color? color;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 45,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color ?? const Color(0xffFF7622),
        ),
        child: Center(
            child: isloading
                ? const Center(
                    child: SpinKitCircle(
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  )),
      ),
    );
  }
}
