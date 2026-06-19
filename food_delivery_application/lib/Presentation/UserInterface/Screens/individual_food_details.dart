import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/outline_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/request_orders.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/rating_and_time.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class IndividualFoodDetails extends StatefulWidget {
  const IndividualFoodDetails({
    required this.product,
    super.key,
  });
  final ProductModel product;
  @override
  State<IndividualFoodDetails> createState() => _IndividualFoodDetailsState();
}

class _IndividualFoodDetailsState extends State<IndividualFoodDetails> {
  @override
  void initState() {
    super.initState();
    // Track popularity when user views details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().trackProductClick(widget.product.productId);
    });
  }

  Map<String, dynamic>? paymentData;
  int count = 1;
  bool isloading = false;
  bool isloading2 = false;
  List<Map<String, dynamic>> ingridents = [];
  @override
  Widget build(BuildContext context) {
    double productPrice = widget.product.productPrice;
    double totalPrice = productPrice * count;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildProductImage(
                  widget.product.productImage.isNotEmpty
                      ? widget.product.productImage
                      : widget.product.imageBase64,
                  width: double.infinity,
                  height: screenHeight(context) * 0.25,
                  fit: BoxFit.cover,
                )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(width: 0.6, color: const Color(0xffE9E9E9))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 15,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    widget.product.productOwner,
                    style: const TextStyle(fontSize: 13),
                  )
                ],
              ),
            ),
            Text(
              widget.product.productName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.product.productDiscription,
              style: const TextStyle(fontSize: 12, color: Color(0xffA0A5BA)),
            ),
            RatingAndTimeWidget(
              product: widget.product,
            ),
            if (ingridents.isNotEmpty) ...[
              const Text('INGREDIENTS'),
              SizedBox(
                height: screenHeight(context) * 0.09,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ingridents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: AppColor.lightOrangeColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: Image.asset(ingridents[index]['image']!),
                        ),
                      );
                    }),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${(productPrice * count).toInt()}',
                  style: const TextStyle(
                    fontSize: 26,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xff121223)),
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (count > 0) {
                              setState(() {
                                count--;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xff41404f)),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          count.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              count++;
                              totalPrice = productPrice * count;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xff41404f)),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            count > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenWidth(context) * 0.32,
                        child: BorderButton(
                            borderColor: AppColor.orangeColor,
                            textColor: AppColor.orangeColor,
                            value: 10,
                            isloading: isloading2,
                            onTap: () async {
                              try {
                                setState(() {
                                  isloading2 = true;
                                });
                                log('1');
                                await makePayment(totalPrice);
                                
                                // Place the order in Firestore after successful payment
                                if (mounted) {
                                  final auth = context.read<AuthController>();
                                  await context.read<ProductController>().sendOrderRequest(
                                      products: [widget.product],
                                      uid: auth.appUser!.id,
                                      address: "Location: ${auth.appUser!.lat}, ${auth.appUser!.lon}",
                                      user: auth.appUser!
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColor.mediumOrangeColor,
                                      content: Text("Order Confirmed & Placed"),
                                    ),
                                  );
                                }

                                setState(() {
                                  isloading2 = false;
                                });
                                log('2');
                              } catch (e) {
                                log('Order error: $e');
                                isloading2 = false;
                                if (mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text("Failed to place order: $e"),
                                    ),
                                  );
                                }
                              }

                              // try {
                              //   setState(() {
                              //     isloading2 = true;
                              //   });
                              //   await context
                              //       .read<ProductController>()
                              //       .addToCart(
                              //           product: widget.product,
                              //           totalPrice: totalPrice.toString(),
                              //           size: 10.toString(),
                              //           uid: context
                              //               .read<AuthController>()
                              //               .appUser!
                              //               .id,
                              //           qunatity: count.toString());
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //       const SnackBar(
                              //           behavior: SnackBarBehavior.floating,
                              //           margin: EdgeInsets.all(5),
                              //           duration: Duration(seconds: 1),
                              //           backgroundColor:
                              //               AppColor.mediumOrangeColor,
                              //           content: Text("Added To CART")));
                              //   // ignore: use_build_context_synchronously
                              //   // Navigator.push(
                              //   //   context,
                              //   //   MaterialPageRoute(
                              //   //     builder: (context) => const MyCart(),
                              //   //   ),

                              //   setState(() {
                              //     isloading2 = false;
                              //   });
                              // } catch (e) {
                              //   isloading2 = false;
                              // }
                            },
                            text: 'CHECK OUT'),
                      ),
                      SizedBox(
                        width: screenWidth(context) * 0.6,
                        child: NormalButton(
                            isloading: isloading,
                            onTap: () async {
                              try {
                                setState(() {
                                  isloading = true;
                                });
                                await context
                                    .read<ProductController>()
                                    .addToCart(
                                        product: widget.product,
                                        totalPrice: totalPrice.toString(),
                                        size: 10.toString(),
                                        uid: context
                                            .read<AuthController>()
                                            .appUser!
                                            .id,
                                        qunatity: count.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                        duration: Duration(seconds: 1),
                                        backgroundColor:
                                            AppColor.mediumOrangeColor,
                                        content: Text("Added To CART")));
                                // ignore: use_build_context_synchronously
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const MyCart(),
                                //   ),

                                setState(() {
                                  isloading = false;
                                });
                              } catch (e) {
                                isloading = false;
                              }
                            },
                            text: 'ADD TO CART'),
                      ),
                    ],
                  )
                : NormalButton(
                    color: Colors.grey.shade500,
                    onTap: () {},
                    text: 'ADD TO CART',
                    isloading: false)
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(double totalPrice) async {
    try {
      paymentData = await createPaymentIntent(totalPrice.toStringAsFixed(0), 'PKR');
      log(paymentData.toString());

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentData!['client_secret'],
            googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US'),
            merchantDisplayName: 'LYS'),
      );
      await displayPayment();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> displayPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();

      setState(() {
        paymentData = null;
      });
      context.mySnackBar(text: 'success');
    } catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      final price = int.parse(amount) * 100;
      Map<String, dynamic> body = {
        'amount': price.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      final response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
                        'Authorization': 'Bearer ' + 'sk_test_51PR9ns02ebwj0k9OG63dkyy244LVeOXT5Gs' + 
                             'ZaKAjyFvPcUoZSkSWEqtfWzDdKjFfpXkzqjKvNTZqNEqhcMkNbGly00UNPBJS8R',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }
}
