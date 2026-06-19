import 'dart:convert' show base64Decode;
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chefId = context.read<AuthController>().appUser!.id;
      context.read<ProductController>().getChefProducts(chefId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'My Food List',
            style: TextStyle(fontSize: 17),
          ),
        ),
        body: Column(
          children: [
            const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColor.orangeColor,
              indicatorColor: AppColor.orangeColor,
              tabs: [
                Tab(
                  child: Text('All'),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                StreamBuilder<List<ProductModel>>(
                  stream: context.read<ProductController>().chefProductsStream(context.read<AuthController>().appUser!.id),
                  builder: (context, snapshot) {
                    final products = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products added yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.deepOrange.shade100,
                                ),
                                height: screenHeight(context) * 0.12,
                                width: screenWidth(context) * 0.32,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: buildProductImage(
                                    product.productImage,
                                    width: screenWidth(context) * 0.32,
                                    height: screenHeight(context) * 0.12,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: screenHeight(context) * 0.12,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: screenWidth(context) * 0.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.productName,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.more_horiz)
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth(context) * 0.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.orange.shade100,
                                              ),
                                              padding: const EdgeInsets.all(3),
                                              child: Text(product.catagory,
                                                  style: const TextStyle(
                                                      color: Colors.deepOrange)),
                                            ),
                                            Text('Rs. ${product.productPrice}')
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(),
                                             Text(
                                               product.isAvailable ? 'Available' : 'Out of Stock',
                                               style: TextStyle(
                                                   color: product.isAvailable ? Colors.green : Colors.red,
                                                   fontSize: 13.5),
                                             )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
