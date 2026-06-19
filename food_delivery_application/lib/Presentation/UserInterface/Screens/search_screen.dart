import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/individual_food_details.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final String keyword;
  const SearchScreen({super.key, required this.keyword});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.keyword.trim().isEmpty) {
        context.read<ProductController>().getProducts();
      } else {
        // 🔴 Pass sortByRating: true for rating-based sorting
        context.read<ProductController>().getSearchProducts(
          search: widget.keyword,
          sortByRating: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.keyword}"'),
      ),
      body: Consumer<ProductController>(
        builder: (context, controller, child) {
          if (controller.isloading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.searchProductList.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: controller.searchProductList.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final product = controller.searchProductList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildProductImage(
                      product.productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔴 ADD RATING ROW
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < product.averageRating.floor()
                                  ? Icons.star
                                  : i < product.averageRating.ceil()
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 14,
                            )),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.totalRatingsCount} reviews)',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(product.catagory),
                      Text(
                        'By: ${product.productOwner}',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rs. ${product.productPrice}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndividualFoodDetails(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}