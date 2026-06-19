import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/recommendation_screen.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/chef_text_field.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/map.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/category_food_items.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/restaurant_view.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/categories_card.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/restaurants.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/user_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/individual_food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/search_screen.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/recommendation_repo.dart';
import 'package:food_delivery_app_project/Data/DataSource/local_recommendation_engine.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _isLoading = true; // Add loading state
  List<ProductRecommendation> aiRecommendations = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    try {
      final auth = context.read<AuthController>();
      final prod = context.read<ProductController>();
      final addr = context.read<AddressController>();

      // 1. Skip re-hydrating user if already present from Splash
      if (auth.appUser == null) {
        await auth.checkCurrentUser(context);
      }
      
      final appUser = auth.appUser;
      
      // 2. Parallelize only MISSING tasks
      await Future.wait([
        if (prod.productList.isEmpty) prod.getProducts(),
        if (appUser != null && addr.addressList.isEmpty) addr.getAdress(uid: appUser.id),
        if (appUser != null) prod.getCartCount(uid: appUser.id),
      ]);

      if (prod.productList.isNotEmpty) {
        if (auth.restaurantList.isEmpty) {
          await auth.getRestaurants(product: prod.productList);
        }
        
        // Final AI sync in background to remove UI spinner lag
        prod.syncDataWithAI().then((_) async {
          if (mounted) {
            final repo = RecommendationRepo();
            final recs = await repo.getTopRated();
            setState(() {
              aiRecommendations = recs.where((rec) {
                final p = rec.product;
                return p.productImage.trim().isNotEmpty && 
                       p.productImage != 'null' && 
                       p.productImage != 'None' && 
                       p.productImage.length > 5;
              }).toList();
            });
          }
        });
      }
    } catch (e) {
      print("Dashboard Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Afternoon';
    if (hour < 12) {
      greeting = 'Good Morning !';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon !';
    } else {
      greeting = 'Good Evening !';
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const UserListTile(),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Hey ${context.watch<AuthController>().appUser?.name ?? 'User'}, ',
                        ),
                        TextSpan(
                            text: greeting,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // AI Food Suggestions Banner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepOrange, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Food Suggestions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Smart picks just for you',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Food Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: screenHeight(context) * 0.28,
                child: StreamBuilder<List<ProductModel>>(
                  stream: context.read<ProductController>().allProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Products Available'));
                    }
                    
                    final validProducts = snapshot.data!.where((p) {
                      return p.productImage.trim().isNotEmpty && 
                             p.productImage != 'null' && 
                             p.productImage != 'None' && 
                             p.productImage.length > 5;
                    }).toList();

                    if (validProducts.isEmpty) {
                      return const Center(child: Text('No Products Available'));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: validProducts.length,
                      itemBuilder: (context, index) {
                        final product = validProducts[index];

                        return GestureDetector(
                          onTap: () {
                            context.read<ProductController>().trackProductClick(product.productId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndividualFoodDetails(
                                  product: product,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: screenWidth(context) * 0.45,
                              child: CategoryFoodItem(
                                product: product,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chef Food Available',
                    style: TextStyle(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AllChefsScreen(),
                      //   ),
                      //);
                    },
                    child: const Text(
                      'See All ',
                      style: TextStyle(
                          color: Colors.deepOrange,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.deepOrange),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: screenHeight(context) * 0.41,
                child: Consumer<AuthController>(builder: (context, value, _) {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: value.restaurantList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantView(
                                    user: context
                                        .read<AuthController>()
                                        .restaurantList[index],
                                  ),
                                ),
                              );
                            },
                            child: Restaurants(
                              user: context
                                  .read<AuthController>()
                                  .restaurantList[index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
