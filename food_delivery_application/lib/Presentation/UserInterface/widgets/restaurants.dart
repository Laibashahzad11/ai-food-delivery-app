import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:provider/provider.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({
    required this.user,
    super.key,
  });
  final UserModel user;

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewController>().getReviewAverage(uid: widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<ProductController>().chefProductsStream(widget.user.id),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.user.userImage != null && widget.user.userImage!.isNotEmpty
                    ? buildProductImage(
                        widget.user.userImage!,
                        height: screenHeight(context) * 0.22,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: screenHeight(context) * 0.22,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Available Food: ${products.length}',
              style: const TextStyle(fontSize: 13, color: Color(0xffA0A5BA)),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: screenWidth(context) * 0.58,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        color: AppColor.orangeColor,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        context.watch<ReviewController>().reviewAverage.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        );
      },
    );
  }
}
