import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Domain/model/review_model.dart';

class ReviewRepo {

  Future<void> addReview({required ReviewModel review}) async {
    try {
      // 🔴 FIX: Pehle unique ID banao
      final String reviewId = FirebaseFirestore.instance.collection('reviews').doc().id;

      // Phir us ID ko use karo
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(review.toId)
          .collection('myReviews')
          .doc(reviewId)  // ← Unique ID use karo
          .set(review.toJson());

      print('✅ Review saved successfully with ID: $reviewId');
    } catch (e) {
      print('❌ Error saving review: $e');
      rethrow;
    }
  }

  Future<int> userReviewLength({required String uid}) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reviews')
          .doc(uid)
          .collection('myReviews')
          .get();
      return doc.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getReviewAverage({required String uid}) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['averageRating']?.toDouble() ?? 0.0);
      }
      return 0.0;
    } catch (e) {
      rethrow;
    }
  }
}