import 'dart:convert' show base64Decode;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/individual_food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/restaurants.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';

class CategoryFoodItems extends StatefulWidget {
  CategoryFoodItems({super.key, required this.title});
  String title;
  @override
  State<CategoryFoodItems> createState() => _CategoryFoodItemsState();
}

class _CategoryFoodItemsState extends State<CategoryFoodItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text('Popular ${widget.title}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<List<ProductModel>>(
                stream: context.read<ProductController>().categoryProductsStream(widget.title),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading products'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found in this category'));
                  }
                  // UI-level strict safety check
                  final data = snapshot.data!.where((p) {
                    return p.productImage.trim().isNotEmpty && 
                           p.productImage != 'null' && 
                           p.productImage != 'None' && 
                           p.productImage.length > 5;
                  }).toList();

                  if (data.isEmpty) {
                    return const Center(child: Text('No products with valid images found'));
                  }

                  return SizedBox(
                    height: screenHeight(context) * 0.46,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 7),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndividualFoodDetails(
                                      product: data[index]),
                                ),
                              );
                            },
                            child: CategoryFoodItem(
                              product: data[index],
                            ));
                      },
                    ),
                  );
                }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'Open Restaurants',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight(context) * 0.32,
              child: Consumer<AuthController>(
                builder: (context, auth, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                    itemCount: auth.restaurantList.length,
                    itemBuilder: (context, index) {
                      return Restaurants(user: auth.restaurantList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryFoodItem extends StatelessWidget {
  const CategoryFoodItem({
    this.product,
    super.key,
  });
  final ProductModel? product;
  @override
  Widget build(BuildContext context) {
    return Container(
      // Adjust this value to increase height
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 25,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth(context) * 0.4,
            height: screenHeight(context) * 0.11,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildProductImage(product!.productImage),
              ),
            ),
          ),
          Text(
            product!.productName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
          Text(
            product!.productOwner,
            style: const TextStyle(
                color: Color(0xff646982),
                fontSize: 13,
                overflow: TextOverflow.ellipsis),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${product!.productPrice.toInt()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Builder(builder: (context) {
                          double raw = product!.averageRating > 0
                              ? product!.averageRating
                              : (product!.productRating ?? 0.0);
                          int rating = raw > 0 ? raw.round().clamp(1, 5) : 3;
                          return Text(
                            '$rating',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String image) {
    if (image.startsWith('data:image')) {
      final base64String = image.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: image,
      placeholder: (context, url) => const SpinKitCircle(
        color: AppColor.mediumOrangeColor,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
