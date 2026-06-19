import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:provider/provider.dart';

class RestaurantRating extends StatefulWidget {
  const RestaurantRating({
    required this.user,
    super.key,
  });
  final UserModel user;

  @override
  State<RestaurantRating> createState() => _RestaurantRatingState();
}

class _RestaurantRatingState extends State<RestaurantRating> {
  double averageRating = 0.0;
  int totalReviews = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateRestaurantRating();
  }

  Future<void> _calculateRestaurantRating() async {
    setState(() => isLoading = true);

    try {
      // Get all products of this restaurant/chef
      final QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productUid', isEqualTo: widget.user.id)
          .get();

      double totalRatingSum = 0;
      int totalReviewsCount = 0;

      for (var doc in productSnapshot.docs) {
        final product = ProductModel.fromJson(doc.data() as Map<String, dynamic>);
        totalRatingSum += product.averageRating * product.totalRatingsCount;
        totalReviewsCount += product.totalRatingsCount;
      }

      setState(() {
        averageRating = totalReviewsCount > 0
            ? totalRatingSum / totalReviewsCount
            : 0.0;
        totalReviews = totalReviewsCount;
        isLoading = false;
      });

      // Also update in ReviewController for other parts of app
      if (mounted) {
        context.read<ReviewController>().reviewAverage = averageRating;
      }

    } catch (e) {
      print('Error calculating restaurant rating: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rating Section with Stars
          Row(
            children: [
              // Star rating display
              if (!isLoading)
                Row(
                  children: List.generate(5, (i) {
                    if (i < averageRating.floor()) {
                      return const Icon(
                        Icons.star,
                        color: AppColor.orangeColor,
                        size: 16,
                      );
                    } else if (i < averageRating.ceil()) {
                      return const Icon(
                        Icons.star_half,
                        color: AppColor.orangeColor,
                        size: 16,
                      );
                    } else {
                      return const Icon(
                        Icons.star_border,
                        color: AppColor.orangeColor,
                        size: 16,
                      );
                    }
                  }),
                )
              else
                const SizedBox(
                  width: 75,
                  child: LinearProgressIndicator(),  // Remove strokeWidth parameter
                ),
              const SizedBox(width: 5),

              // Rating number
              Text(
                isLoading ? '--' : averageRating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 5),

              // Total reviews count
              if (!isLoading)
                Text(
                  '($totalReviews)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
            ],
          ),

          // Delivery fee
          Row(
            children: [
              Image.asset(
                'assets/images/Car.png',
                color: AppColor.orangeColor,
                height: 18,
              ),
              const SizedBox(width: 5),
              const Text('Free'),
            ],
          ),

          // Delivery time
          Row(
            children: [
              Image.asset(
                'assets/images/Watch.png',
                color: AppColor.orangeColor,
                height: 18,
              ),
              const SizedBox(width: 5),
              const Text('20 min'),
            ],
          ),
        ],
      ),
    );
  }
}