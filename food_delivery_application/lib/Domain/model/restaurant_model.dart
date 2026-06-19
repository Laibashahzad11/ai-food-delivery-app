class RestaurantModel {
  final String name;
  final String city;
  final String cuisines;
  final double rating;
  final int reviewsCount;
  final String priceCategory;
  final double? matchScore;
  final double? similarityScore;

  RestaurantModel({
    required this.name,
    required this.city,
    required this.cuisines,
    required this.rating,
    required this.reviewsCount,
    required this.priceCategory,
    this.matchScore,
    this.similarityScore,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      name: json['restaurant_name'] ?? '',
      city: json['city'] ?? '',
      cuisines: json['cuisines'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      priceCategory: json['price_category'] ?? 'medium',
      matchScore: json['match_score']?.toDouble(),
      similarityScore: json['similarity_score']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_name': name,
      'city': city,
      'cuisines': cuisines,
      'rating': rating,
      'reviews_count': reviewsCount,
      'price_category': priceCategory,
      if (matchScore != null) 'match_score': matchScore,
      if (similarityScore != null) 'similarity_score': similarityScore,
    };
  }
}
