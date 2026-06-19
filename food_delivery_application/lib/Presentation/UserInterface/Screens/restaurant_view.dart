import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/individual_food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/category_food_items.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/restaurant_rating_time.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';

class RestaurantView extends StatefulWidget {
  const RestaurantView({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  State<RestaurantView> createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant View'),
      ),
      body: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            // ✅ Fixed content (non-scrollable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/restaurant.jpg',
                      height: screenHeight(context) * 0.22,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.resturantName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to ${widget.user.resturantName}. Explore our delicious offerings below.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xffA0A5BA),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Sirf ek RestaurantRating (duplicate hata diya)
                  RestaurantRating(user: widget.user),
                  const SizedBox(height: 10),

                  // ✅ TabBar sahi jagah
                  SizedBox(
                    width: screenWidth(context),
                    child: TabBar(
                      tabAlignment: TabAlignment.center,
                      padding: EdgeInsets.zero,
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: AppColor.mediumOrangeColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return null;
                        },
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      tabs: const [
                        Tab(child: Text('Burger')),
                        Tab(child: Text('Pizza')),
                        Tab(child: Text('Sandwich')),
                        Tab(child: Text('Soup')),
                        Tab(child: Text('Nuggets')),
                        Tab(child: Text('Other')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ✅ Scrollable TabBarView
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: context
                    .read<ProductController>()
                    .chefProductsStream(widget.user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allChefProducts = snapshot.data ?? [];

                  if (allChefProducts.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }

                  return TabBarView(
                    children: [
                      _buildCategoryGrid('Burger', allChefProducts),
                      _buildCategoryGrid('Pizza', allChefProducts),
                      _buildCategoryGrid('Sandwich', allChefProducts),
                      _buildCategoryGrid('Soup', allChefProducts),
                      _buildCategoryGrid('Nuggets', allChefProducts),
                      _buildCategoryGrid('Other', allChefProducts),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(String category, List<ProductModel> allProducts) {
    final filteredProducts =
    allProducts.where((p) => p.catagory == category).toList();

    if (filteredProducts.isEmpty) {
      return Center(child: Text('No $category Products available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return GestureDetector(
          onTap: () {
            context
                .read<ProductController>()
                .trackProductClick(product.productId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndividualFoodDetails(product: product),
              ),
            );
          },
          child: CategoryFoodItem(product: product),
        );
      },
    );
  }
}