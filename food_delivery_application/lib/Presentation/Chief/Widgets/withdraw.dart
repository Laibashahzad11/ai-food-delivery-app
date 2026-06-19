import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: screenHeight(context) * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColor.orangeColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    right: -45,
                    top: -40,
                    child: Image.asset('assets/images/star.png'),
                  ),
                  Positioned(
                    left: -15,
                    top: -30,
                    child: Image.asset('assets/images/star.png'),
                  ),
                  Positioned(
                    left: -90,
                    top: -0,
                    bottom: 0,
                    child: Image.asset('assets/images/Ellipse.png'),
                  ),
                  Positioned(
                    right: 30,
                    top: -30,
                    child: Image.asset('assets/images/Ellipse.png'),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Image.asset('assets/images/star.png'),
                  ),
                  Positioned(
                    left: -15,
                    top: -80,
                    child: Image.asset('assets/images/Vec.png'),
                  ),
                  Positioned(
                      right: -90,
                      top: 0,
                      bottom: 0,
                      child: Image.asset('assets/images/Vec.png'))
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Withdraw Successful',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: NormalButton(
                  isloading: false,
                  text: 'OK',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
