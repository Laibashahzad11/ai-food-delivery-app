import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recommendation_response.dart';
import '../models/restaurant.dart';

class RecommendationService {
  
  // Singleton pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  /// Search for restaurants using natural language query
  Future<RecommendationResponse> searchRestaurants(String query, {int topN = 5}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.searchEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'top_n': topN,
        }),
      );

      if (response.statusCode == 200) {
        return RecommendationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Find similar restaurants
  Future<RecommendationResponse> getSimilarRestaurants(String restaurantName, {int topN = 5}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.similarEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'restaurant_name': restaurantName,
          'top_n': topN,
        }),
      );

      if (response.statusCode == 200) {
        return RecommendationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to find similar restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get top rated restaurants
  Future<RecommendationResponse> getTopRated({String? city, String? cuisine, int topN = 10}) async {
    try {
      final queryParams = {
        'top_n': topN.toString(),
        if (city != null) 'city': city,
        if (cuisine != null) 'cuisine': cuisine,
      };

      final uri = Uri.parse(ApiConfig.topRatedEndpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // The current top-rated-simple endpoint returns a structure that matches RecommendationResponse
        // based on test_api.py analysis (line 325 -> engine.get_top_rated -> line 315)
        // It returns { success, type, filters, recommendations: [...] }
        // Our RecommendationResponse expects showing/total_found which might be missing but handled by defaults?
        // Let's check RecommendationResponse.fromJson defaults.
        // Yes: totalFound defaults to 0, showing defaults to 0.
        // However, we should verify the backend response structure.
        return RecommendationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load top rated restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
