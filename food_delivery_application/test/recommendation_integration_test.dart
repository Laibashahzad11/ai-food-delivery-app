import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app_project/Domain/model/restaurant_model.dart';
import 'package:food_delivery_app_project/Domain/model/recommendation_response_model.dart';

void main() {
  group('Main App Recommendation Integration Tests', () {
    test('RestaurantModel.fromJson parses correctly', () {
      final json = {
        'restaurant_name': 'Karachi Foods',
        'city': 'Karachi',
        'cuisines': 'Biryani, BBQ',
        'rating': 4.8,
        'reviews_count': 500,
        'price_category': 'medium',
        'match_score': 90.0
      };

      final restaurant = RestaurantModel.fromJson(json);
      expect(restaurant.name, 'Karachi Foods');
      expect(restaurant.matchScore, 90.0);
    });

    test('RecommendationResponseModel.fromJson parses correctly', () {
       final json = {
        'success': true,
        'type': 'query',
        'total_results': 1,
        'showing': 1,
        'recommendations': []
      };
      
      final response = RecommendationResponseModel.fromJson(json);
      expect(response.success, true);
    });
  });
}
