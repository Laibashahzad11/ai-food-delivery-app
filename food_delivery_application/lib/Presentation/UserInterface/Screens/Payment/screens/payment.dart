import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import '../../../Commens/back_button.dart';
import '../widgets/payment_method_container.dart';

class Payment extends StatefulWidget {
  const Payment({
    super.key,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  const CustomBackButton(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Payment",
                      style: TextStyles.largeSen(context)
                          .copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PaymentMethodContainer(
                    ontap: () {},
                    icon: Icons.cast_sharp,
                    text: "Cash",
                  ),
                  PaymentMethodContainer(
                    ontap: () {},
                    icon: Icons.abc,
                    text: "Easypaisa",
                  ),
                  PaymentMethodContainer(
                    ontap: () {},
                    icon: Icons.flag,
                    text: "Mastercard",
                  ),
                  PaymentMethodContainer(
                    ontap: () {},
                    icon: Icons.no_drinks,
                    text: "Paypal",
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColor.lightGreyColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("assets/images/No master card.PNG"),
                      Text(
                        "No Master Card Added",
                        style: TextStyles.medSen(context)
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        "You Can Add a Master Card and Save It For Letter",
                        style: TextStyles.ragularSen(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: AppColor.lightGreyColor,
                      width: 2,
                    ),
                  ),
                  padding: const MaterialStatePropertyAll(
                    EdgeInsets.all(20),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColor.orangeColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "ADD CARD",
                      style: TextStyles.medSen(context)
                          .copyWith(color: AppColor.orangeColor),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                child: Row(
                  children: [
                    Text(
                      "TOTAL:",
                      style: TextStyles.medSen(context).copyWith(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "RS",
                      style: TextStyles.ragularSen(context).copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "96",
                      style: TextStyles.ragularSen(context).copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
