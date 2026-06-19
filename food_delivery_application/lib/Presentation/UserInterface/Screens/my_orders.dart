import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/review_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/outline_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/request_orders.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/call_screen.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/message_screen.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/track_order.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<Map<String, dynamic>> rate = [
    {
      'point': 1,
      'text': 'Bad',
    },
    {
      'point': 2,
      'text': 'So So',
    },
    {
      'point': 3,
      'text': 'Good',
    },
    {
      'point': 4,
      'text': 'Great',
    },
    {
      'point': 5,
      'text': 'Excelent',
    }
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColor.orangeColor,
              indicatorColor: AppColor.orangeColor,
              tabs: [
                Tab(
                  child: Text('Ongoing'),
                ),
                Tab(
                  child: Text('History'),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('sendRequests')
                        .doc(context.read<AuthController>().appUser!.id)
                        .collection('sentOrders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // final data = snapshot.data?.docs
                      //     .map((e) =>
                      //         ProductModel.fromJson(e.data()))
                      //     .toList();
                      // log(snapshot.data?.docs
                      //     .map((e) => e.data()));
                      // print(data?.length ?? 0);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Text('data');
                      } else if (!snapshot.hasData) {
                        return const Text('Empty');
                      }
                      final data = snapshot.data!.docs.map((doc) {
                        final orderData = doc.data();
                        final products = (orderData['products'] as List)
                            .map((product) => ProductModel.fromJson(product))
                            .toList();
                        return {
                          'products': products,
                          'timestamp': orderData['timestamp'],
                          'docId': orderData['docId'],
                        };
                      }).toList();
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final products =
                              item['products'] as List<ProductModel>;
                          print(data);
                          print(item);
                          print(products);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                              child: SizedBox(
                                height: screenHeight(context) * 0.26,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: products.map((product) {
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Food'),
                                                  SizedBox(
                                                    width: 100,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        250),
                                                                () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CallSceen(
                                                                    productModel:
                                                                        product,
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            child: Image.asset(
                                                              'assets/images/telephone.png',
                                                              height: 22,
                                                              color: AppColor
                                                                  .orangeColor,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        250),
                                                                () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MessageScreen(
                                                                    product:
                                                                        product,
                                                                    user: context
                                                                        .read<
                                                                            AuthController>()
                                                                        .appUser!,
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            child: Image.asset(
                                                              'assets/images/messenger.png',
                                                              height: 22,
                                                              color: AppColor
                                                                  .orangeColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              height:
                                                  90, // Set the desired height here
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.grey[300],
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            product
                                                                .productImage),
                                                        fit: BoxFit
                                                            .cover, // Ensure the image covers the container
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          10), // Add some spacing between the image and the text
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product.productName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                'Rs. ${product.productPrice}'),
                                                            const Text('  |  '),
                                                            // Container(
                                                            //   height: 6,
                                                            //   width: 6,
                                                            //   decoration:
                                                            //       BoxDecoration(
                                                            //     color:
                                                            //         Colors.grey,
                                                            //     borderRadius:
                                                            //         BorderRadius
                                                            //             .circular(
                                                            //                 10),
                                                            //   ),
                                                            // ),
                                                            Text(
                                                                ' ${product.quantity} Items')
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                NormalButton(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              TrackOrder(
                                                            product: product,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    text: 'Track Order',
                                                    isloading: false),
                                                BorderButton(
                                                    borderColor:
                                                        AppColor.orangeColor,
                                                    textColor:
                                                        AppColor.orangeColor,
                                                    text: 'Cancel',
                                                    value: 35,
                                                    onTap: () {},
                                                    isloading: false)
                                              ],
                                            )
                                          ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(context.read<AuthController>().appUser!.id)
                      .collection('history')
                      .snapshots(),
                  builder: (context, snapshot) {
                    print('=== HISTORY DEBUG ===');
                    print('Has data: ${snapshot.hasData}');
                    print('Connection state: ${snapshot.connectionState}');
                    print('Docs length: ${snapshot.data?.docs.length}');
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      print('First doc: ${snapshot.data!.docs.first.data()}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('data');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('NO HISTORY'));
                    }
                    final data = snapshot.data!.docs
                        .map((e) => ProductModel.fromJson(e.data()))
                        .toList();
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final singleProduct = data[index];
                        log(singleProduct.toString());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                height: screenHeight(context) * 0.22,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        child: Text('Food'),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        height:
                                            90, // Set the desired height here
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[300],
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      singleProduct
                                                          .productImage),
                                                  fit: BoxFit
                                                      .cover, // Ensure the image covers the container
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Add some spacing between the image and the text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    singleProduct.productName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          'Rs. ${singleProduct.productPrice}'),
                                                      const Text('  |  '),
                                                      // Container(
                                                      //   height: 6,
                                                      //   width: 6,
                                                      //   decoration:
                                                      //       BoxDecoration(
                                                      //     color:
                                                      //         Colors.grey,
                                                      //     borderRadius:
                                                      //         BorderRadius
                                                      //             .circular(
                                                      //                 10),
                                                      //   ),
                                                      // ),
                                                      Text(
                                                          ' ${singleProduct.quantity} Items')
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          NormalButton(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return RatingAlert(
                                                      rate: rate,
                                                      toId: singleProduct
                                                          .productUid,
                                                      product: singleProduct,
                                                    );
                                                  },
                                                );
                                              },
                                              width: screenWidth(context) * 0.3,
                                              text: 'RATE',
                                              isloading: false),
                                          BorderButton(
                                              borderColor: AppColor.orangeColor,
                                              textColor: AppColor.orangeColor,
                                              text: 'Re order',
                                              value: 35,
                                              onTap: () {},
                                              isloading: false)
                                        ],
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingAlert extends StatefulWidget {
  const RatingAlert({
    super.key,
    required this.rate,
    required this.toId,
    required this.product,
  });

  final List<Map<String, dynamic>> rate;
  final String toId;
  final ProductModel product;

  @override
  State<RatingAlert> createState() => _RatingAlertState();
}

class _RatingAlertState extends State<RatingAlert> {
  final titleController = TextEditingController();
  final reviewController = TextEditingController();
  final ratingController = TextEditingController();
  bool isloading = false;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AlertDialog(
        backgroundColor: Colors.white,
        content: SizedBox(
          width: screenWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/rate.png',
                height: 50,
                color: AppColor.mediumOrangeColor,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validate.name,
                controller: titleController,
                decoration: Data().decoration(context, 'Enter Title ', null),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validate.name,
                controller: reviewController,
                decoration: Data().decoration(context, 'Enter Review ', null),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: Validate.number,
                keyboardType: TextInputType.number,
                controller: ratingController,
                decoration:
                    Data().decoration(context, 'Rating (1 to 5) ', null),
              ),
            ],
          ),
        ),
        actions: [
          NormalButton(
              onTap: () async {
                print('🔴 BUTTON CLICKED 🔴');  // ← DEBUG LINE

                if (formKey.currentState!.validate()) {
                  print('✅ Form Validated');  // ← DEBUG LINE
                  print('📝 Rating value: ${ratingController.text}');  // ← DEBUG LINE
                  print('📝 Title: ${titleController.text}');  // ← DEBUG LINE
                  print('📝 Review: ${reviewController.text}');  // ← DEBUG LINE

                  try {
                    setState(() {
                      isloading = true;
                    });

                    final review = ReviewModel(
                      rating: int.parse(ratingController.text),
                      reviewMessage: reviewController.text,
                      reviewTime: DateTime.now(),
                      reviewTitle: titleController.text,
                      userimage: context.read<AuthController>().appUser!.userImage,
                      id: context.read<AuthController>().appUser!.id,
                      toId: widget.product.productUid,
                      productId: widget.product.productId,
                    );

                    print('📦 Review object created');  // ← DEBUG LINE
                    print('📦 Product ID: ${review.productId}');  // ← DEBUG LINE
                    print('📦 Chef ID: ${review.toId}');  // ← DEBUG LINE

                    await context.read<ReviewController>().addReview(
                      review: review,
                      context: context,
                    );
                    print('✅ Review added and systems synced');

                    print('✅ Product rating updated');  // ← DEBUG LINE

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review Submitted Successfully')),
                    );

                    setState(() {
                      isloading = false;
                    });

                  } catch (e) {
                    print('❌ ERROR: $e');  // ← DEBUG LINE
                    setState(() {
                      isloading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } else {
                  print('❌ Form Validation Failed');  // ← DEBUG LINE
                }
              },
              text: 'SUBMIT REVIEW',
              isloading: isloading)
        ],
      ),
    );
  }
}
