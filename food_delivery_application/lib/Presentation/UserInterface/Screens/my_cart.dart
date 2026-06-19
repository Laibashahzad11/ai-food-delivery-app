// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/address_model.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:provider/provider.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  void initState() {
    context
        .read<ProductController>()
        .getCartTotalPrice(uid: context.read<AuthController>().appUser!.id);
    context
        .read<ProductController>()
        .getCartCount(uid: context.read<AuthController>().appUser!.id);
    context
        .read<AddressController>()
        .getAdress(uid: context.read<AuthController>().appUser!.id);
    super.initState();
  }

  List<ProductModel> cartProducts = [];
  double totalPrice = 0;
  TextEditingController addressController = TextEditingController();
  String value = '';
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Cart'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('cart')
                    .doc(context.read<AuthController>().appUser!.id)
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs
                      .map((e) => ProductModel.fromJson(e.data()))
                      .toList();
                  cartProducts = data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Items In The Cart',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final data1 = data[index];
                      return SizedBox(
                        width: screenWidth(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodDetails(
                                        product: data1,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade100,
                                  ),
                                  height: screenHeight(context) * 0.13,
                                  width: screenWidth(context) * 0.26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: data1.productImage,
                                      placeholder: (context, url) =>
                                      const SpinKitCircle(
                                        color: AppColor.mediumOrangeColor,
                                      ),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: screenHeight(context) * 0.14,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                maxLines: 1,
                                                data1.productName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await context
                                                    .read<ProductController>()
                                                    .removeItemFromCart(
                                                  uid: context
                                                      .read<AuthController>()
                                                      .appUser!
                                                      .id,
                                                  productModel: data1,
                                                );
                                                if (mounted) {
                                                  await context
                                                      .read<ProductController>()
                                                      .getCartTotalPrice(
                                                    uid: context
                                                        .read<
                                                        AuthController>()
                                                        .appUser!
                                                        .id,
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: AppColor.orangeColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Rs. ${data1.productPrice}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DELIVERY ADDRESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: 'Type your delivery address here...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.location_pin,
                        color: AppColor.orangeColor,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text(
                        'TOTAL: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Rs. ${context.watch<ProductController>().myCartTotalPrice}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColor.orangeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  cartProducts.isNotEmpty
                      ? NormalButton(
                    isloading: isloading,
                    onTap: () async {
                      if (addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Please enter a delivery address"),
                          ),
                        );
                        return;
                      }
                      try {
                        setState(() {
                          isloading = true;
                        });
                        await context
                            .read<ProductController>()
                            .sendOrderRequest(
                          products: cartProducts,
                          uid: context
                              .read<AuthController>()
                              .appUser!
                              .id,
                          address: addressController.text.trim(),
                          user: context
                              .read<AuthController>()
                              .appUser!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor:
                            AppColor.mediumOrangeColor,
                            content: Text("Order Placed"),
                          ),
                        );
                        if (mounted) {
                          setState(() {
                            isloading = false;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            isloading = false;
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Error Occurred"),
                          ),
                        );
                      }
                    },
                    text: 'PLACE ORDER',
                  )
                      : NormalButton(
                    color: Colors.grey,
                    onTap: () {},
                    text: 'PLACE ORDER',
                    isloading: isloading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}