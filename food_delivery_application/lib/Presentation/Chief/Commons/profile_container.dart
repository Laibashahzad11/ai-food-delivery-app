import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/outline_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/withdraw.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight(context) * 0.2,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColor.mediumOrangeColor,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          const Text(
            'Rs. 500.00',
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: BorderButton(
                isloading: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WithdrawScreen(),
                    ),
                  );
                },
                value: 5,
                borderColor: Colors.white,
                text: 'Withdraw',
                textColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
