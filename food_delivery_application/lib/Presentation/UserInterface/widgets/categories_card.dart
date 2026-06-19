import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';

class CategoriesCard extends StatelessWidget {
  CategoriesCard({
    this.cat,
    this.price,
    this.product,
    super.key,
  });
  final ProductModel? product;
  String? cat;
  String? price;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 1,
                blurRadius: 25,
                blurStyle: BlurStyle.outer)
          ],
          borderRadius: BorderRadius.circular(10)),
      // Set a fixed height for the column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildProductImage(
                product!.productImage,
                width: screenWidth(context) * 0.4,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text(
                cat!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            width: screenWidth(context) * 0.42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Starting',
                  style: TextStyle(fontSize: 13, color: Color(0xff646982)),
                ),
                Text(
                  price!,
                  style: const TextStyle(fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
