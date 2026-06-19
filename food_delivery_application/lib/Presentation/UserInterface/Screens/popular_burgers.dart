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

class PopularBurgers extends StatefulWidget {
  PopularBurgers({super.key, required this.title});
  String title;
  @override
  State<PopularBurgers> createState() => _PopularBurgersState();
}

class _PopularBurgersState extends State<PopularBurgers> {
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
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('catagory', isEqualTo: widget.title)
                    // Assuming you have a document ID here, provide it if not empty
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs
                      .map((e) => ProductModel.fromJson(e.data()))
                      .toList();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('data');
                  } else if (!snapshot.hasData) {
                    return const Text('Empty');
                  }

                  return SizedBox(
                    height: screenHeight(context) * 0.46,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: data?.length ?? 0,
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
                            child: PopularBurgersItem(
                              product: data![index],
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
              child: ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 0),
                  itemCount: 0,
                  itemBuilder: (context, index) {
                    return Restaurants(
                      user:
                          context.read<AuthController>().restaurantList[index],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔴 REPLACE only the PopularBurgersItem class
class PopularBurgersItem extends StatelessWidget {
  const PopularBurgersItem({
    this.product,
    super.key,
  });
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
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
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: product!.productImage,
                  placeholder: (context, url) => const SpinKitCircle(
                    color: AppColor.mediumOrangeColor,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Text(
            product!.productName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            product!.productOwner,
            style: const TextStyle(
              color: Color(0xff646982),
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 🔴 ADD RATING ROW HERE
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Builder(builder: (context) {
                double raw = product!.averageRating > 0 
                  ? product!.averageRating 
                  : (product!.productRating ?? 0.0);
                int rating = raw > 0 ? raw.round().clamp(1, 5) : 3;
                return Text(
                  '$rating',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${product!.productPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  size: 25,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
