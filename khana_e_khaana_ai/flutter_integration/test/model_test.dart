import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_integration/models/restaurant.dart';
import 'package:flutter_integration/models/recommendation_response.dart';

void main() {
  group('Restaurant Model Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'restaurant_name': 'Bundoo Khan',
        'city': 'Lahore',
        'cuisines': 'BBQ, Pakistani',
        'rating': 4.5,
        'reviews_count': 1200,
        'price_category': 'high',
        'match_score': 95.5
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.name, 'Bundoo Khan');
      expect(restaurant.city, 'Lahore');
      expect(restaurant.rating, 4.5);
      expect(restaurant.matchScore, 95.5);
    });
  });

  group('RecommendationResponse Model Tests', () {
    test('fromJson parses correctly with list', () {
      final json = {
        'success': true,
        'type': 'query',
        'total_results': 1,
        'showing': 1,
        'recommendations': [
          {
            'restaurant_name': 'Bundoo Khan',
            'city': 'Lahore',
            'cuisines': 'BBQ',
            'rating': 4.5,
            'reviews_count': 100,
            'price_category': 'high'
          }
        ]
      };

      final response = RecommendationResponse.fromJson(json);

      expect(response.success, true);
      expect(response.totalFound, 1);
      expect(response.recommendations.length, 1);
      expect(response.recommendations.first.name, 'Bundoo Khan');
    });
  });
}
