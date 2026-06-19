import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/review_repo.dart';
import 'package:food_delivery_app_project/Domain/model/review_model.dart';
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewController extends ChangeNotifier {
  final db = ReviewRepo();
  int userReviewLength = 0;
  double reviewAverage = 0;

  Future<void> addReview({required ReviewModel review, required BuildContext context}) async {
    try {
      log('=== ADD REVIEW STARTED ===');
      log('Rating: ${review.rating}');
      log('Product ID: ${review.productId}');

      // 1. Add review to Firebase
      await db.addReview(review: review);
      log('Review saved to Firebase');

      // 2. 🔴 IMPORTANT - Direct product rating update
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(review.productId);

      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final currentTotal = productDoc.data()?['totalRatingsCount'] ?? 0;
        final currentSum = (productDoc.data()?['totalRatingsSum'] ?? 0).toDouble();

        final newTotal = currentTotal + 1;
        final newSum = currentSum + review.rating;
        final newAverage = newSum / newTotal;

        await productRef.update({
          'totalRatingsCount': newTotal,
          'totalRatingsSum': newSum,
          'averageRating': newAverage,
          'productRating': newAverage,
        });

        log('Product rating updated! New average: $newAverage');

        // 3. 🔵 NEW: Notify AI Backend about the new rating
        try {
           final response = await http.post(
             Uri.parse('${ApiConfig.baseUrl}/rate'),
             headers: {'Content-Type': 'application/json'},
             body: jsonEncode({
               'product_id': review.productId,
               'rating': review.rating,
             }),
           ).timeout(const Duration(seconds: 3));
           
           if (response.statusCode == 200) {
             log('AI Backend: Rating synced successfully.');
           }
        } catch (e) {
          log('AI Backend Sync (Rating) failed: $e');
        }

        // 4. 🟡 NEW: Refresh ProductController to update Dashboard UI
        try {
          context.read<ProductController>().getProducts();
        } catch (e) {
          log('Dashboard Refresh failed: $e');
        }
      }

      notifyListeners();
      log('=== ADD REVIEW COMPLETED ===');
    } catch (e) {
      log('Error in addReview: $e');
      rethrow;
    }
  }

  Future<double> getReviewAverage({required String uid}) async {
    try {
      reviewAverage = await db.getReviewAverage(uid: uid);
      log('Review average: $reviewAverage');
      notifyListeners();
      return reviewAverage;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reviewLength({required String uid}) async {
    try {
      userReviewLength = await db.userReviewLength(uid: uid);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}