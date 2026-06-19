import 'package:flutter/material.dart';

import '../../../../../Data/DataSource/Resources/color.dart';

class PaymentMethodContainer extends StatelessWidget {
  const PaymentMethodContainer(
      {required this.ontap, super.key, required this.icon, required this.text});
  final Function() ontap;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: ontap,
          child: Container(
            width: 80,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColor.lightGreyColor,
            ),
            child: Center(
              child: Icon(icon),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(text),
      ],
    );
  }
}
