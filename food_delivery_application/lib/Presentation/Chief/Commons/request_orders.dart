import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/outline_button.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/profile/personal_info.dart';
import 'package:provider/provider.dart';

class RequestOrders extends StatefulWidget {
  const RequestOrders({
    required this.product,
    required this.user,
    required this.docId,
    super.key,
  });
  final ProductModel product;
  final UserModel user;
  final String docId;

  @override
  State<RequestOrders> createState() => _RequestOrdersState();
}

class _RequestOrdersState extends State<RequestOrders> {
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodDetails()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.deepOrange.shade100,
              ),
              height: screenHeight(context) * 0.12,
              width: screenWidth(context) * 0.24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildProductImage(
                  widget.product.productImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(  // 🔴 FIX: Expanded added to prevent overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for Category and Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${widget.product.catagory}',
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInfo(
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.user.userImage ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Product Name
                Text(
                  widget.product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // Price
                Text(
                  'Rs. ${widget.product.productPrice}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.product.deliveryAddress != null &&
                    widget.product.deliveryAddress!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.location_pin,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.product.deliveryAddress!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: NormalButton(
                        isloading: isloading,
                        text: 'Accept',
                        onTap: () async {
                          try {
                            setState(() {
                              isloading = true;
                            });
                            await context
                                .read<ProductController>()
                                .acceptRequest(
                              product: widget.product,
                              user: widget.user,
                            );
                            await context
                                .read<ProductController>()
                                .declineRequest(
                              product: widget.product,
                              uid: context
                                  .read<AuthController>()
                                  .appUser!
                                  .id,
                              docId: widget.docId,
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
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BorderButton(
                        isloading: false,
                        onTap: () async {
                          await context
                              .read<ProductController>()
                              .declineRequest(
                            product: widget.product,
                            uid: context
                                .read<AuthController>()
                                .appUser!
                                .id,
                            docId: widget.docId,
                          );
                        },
                        value: 10,
                        borderColor: const Color(0xffFF7622),
                        text: 'Decline',
                        textColor: const Color(0xffFF7622),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension SnackBarExtension on BuildContext {
  void mySnackBar({required String text}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.mediumOrangeColor,
        content: Text(text),
      ),
    );
  }
}