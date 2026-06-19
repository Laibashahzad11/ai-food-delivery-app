import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewMessage;
  final String reviewTitle;
  final DateTime reviewTime;
  final int rating;
  String? productId;
  final String id;
  final String toId;
  final String? userimage;

  ReviewModel({
    required this.rating,
    required this.reviewMessage,
    required this.reviewTime,
    required this.reviewTitle,
    this.userimage,
    required this.toId,
    required this.id,
    this.productId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
        rating: json['rating'] ?? 0,
        reviewMessage: json['reviewMessage'] ?? '',
        reviewTime: json['reviewTime'] != null 
            ? (json['reviewTime'] as Timestamp).toDate() 
            : DateTime.now(),
        reviewTitle: json['reviewTitle'] ?? '',
        id: json['id'] ?? '',
        toId: json['toId'] ?? '',
        userimage: json['userimage'],
    productId: json['productId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'reviewMessage': reviewMessage,
      'reviewTime': reviewTime,
      'reviewTitle': reviewTitle,
      'id': id,
      'toId': toId,
      'productId': productId,
      'userimage': userimage,
    };
  }
}
