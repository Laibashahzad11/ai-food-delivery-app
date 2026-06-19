import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/review_model.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = context.read<AuthController>().appUser;

    if (appUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reviews')),
        body: const Center(child: Text('User details not found. Please log in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Reviews',
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .doc(appUser.id)
            .collection('myReviews')
            .orderBy('rating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('NO REVIEWS'));
          }

          final data = snapshot.data!.docs
              .map((e) => ReviewModel.fromJson(e.data()))
              .toList();

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final review = data[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: review.userimage != null && review.userimage!.isNotEmpty
                          ? NetworkImage(review.userimage!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      radius: 35,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: screenHeight(context) * 0.14,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewTime != null
                                ? '${review.reviewTime.day}/${review.reviewTime.month}/${review.reviewTime.year}'
                                : 'Unknown date',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            review.reviewTitle ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RatingBar(
                            size: 16,
                            maxRating: 5,
                            filledColor: AppColor.orangeColor,
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star,
                            onRatingChanged: (p0) {},
                            initialRating: review.rating.toDouble(),
                          ),
                          SizedBox(
                            width: screenWidth(context) * 0.7,
                            child: Text(
                              review.reviewMessage ?? 'No comment',
                              style: const TextStyle(
                                color: Color(0xff747783),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension CustomDate on DateTime {
  String get myDate {
    return '$day/$month/$year';
  }
}