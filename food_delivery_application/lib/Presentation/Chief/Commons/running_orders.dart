import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/outline_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:provider/provider.dart';

class RunningOrders extends StatelessWidget {
  const RunningOrders({
    required this.product,
    required this.user,
    required this.docId,
    super.key,
  });
  final ProductModel product;
  final UserModel user;
  final String docId;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth(context) * 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const FoodDetails()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepOrange.shade100,
                  ),
                  height: 100,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildProductImage(product.productImage, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${product.catagory}',
                          style: const TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs. ${product.productPrice}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.productName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (product.deliveryAddress != null &&
                        product.deliveryAddress!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_pin,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.deliveryAddress!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: NormalButton(
                              isloading: false,
                              text: 'Done',
                              onTap: () async {
                                try {
                                  await context
                                      .read<ProductController>()
                                      .completeOrder(product: product, user: user);
                                  await context
                                      .read<ProductController>()
                                      .removeFromUser(
                                          product: product,
                                          uid: context
                                              .read<AuthController>()
                                              .appUser!
                                              .id,
                                          docId: docId);
                                } catch (e) {
                                  rethrow;
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: BorderButton(
                              isloading: false,
                              onTap: () {},
                              value: 10,
                              borderColor: const Color(0xffFF7622),
                              text: 'Cancel',
                              textColor: const Color(0xffFF7622),
                            ),
                          ),
                        ),
                      ],
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
