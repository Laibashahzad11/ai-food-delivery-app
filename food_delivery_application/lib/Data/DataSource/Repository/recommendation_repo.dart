import 'dart:convert';
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Data/DataSource/local_recommendation_engine.dart';
import 'package:http/http.dart' as http;

class RecommendationRepo {
  final LocalRecommendationEngine _localEngine = LocalRecommendationEngine();

  /// Sync data with the local AI engine.
  Future<void> syncData(List<ProductModel> products) async {
    try {
      // 1. Sync with local engine (persists to disk automatically)
      await _localEngine.updateData(products);
      
      // 2. Sync with Python AI Backend for robust matching and auto-rating
      // Uses the dynamic baseUrl from ApiConfig
      final response = await http.post(
        Uri.parse(ApiConfig.syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'products': products.map((p) => p.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        print('AI Sync (Backend): Successfully synchronized with Python server.');
      } else {
        print('AI Sync (Backend) Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Sync (Backend) Error: Network unreachable or timeout ($e)');
      // Local sync already happened above, so we are safe
    }
  }

  /// Performs a search for food items using the remote AI engine with local fallback.
  Future<List<ProductRecommendation>> searchFood(String query, {int topN = 10}) async {
    // Ensure local engine is initialized from disk if it's the first use
    await _localEngine.init();
    
    try {
      // 1. Try Remote AI Engine First (More robust NLP)
      final response = await http.post(
        Uri.parse(ApiConfig.recommendEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'top_n': topN,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // If backend says not available, return empty immediately
        if (data['success'] == false) {
          print('AI Engine: Backend says not available for query: $query');
          return [];
        }

        if (data['success'] == true && data['recommendations'] != null) {
          final List<dynamic> recsRaw = data['recommendations'];
          
          // The Python backend returns formatted items with foodName/price/rating
          // We map these back to ProductModel for display
          final List<ProductRecommendation> results = [];
          for (final json in recsRaw) {
            // Parse price: 'Rs. 400' -> 400.0
            double parsedPrice = 0.0;
            final String rawPrice = (json['price'] ?? '0').toString();
            // Extract numbers including optional decimal point
            final RegExp priceRegex = RegExp(r'(\d+(?:\.\d+)?)');
            final match = priceRegex.firstMatch(rawPrice);
            if (match != null) {
              parsedPrice = double.tryParse(match.group(1)!) ?? 0.0;
            }

            // Parse rating as integer
            final int ratingInt = (json['rating'] as num?)?.toInt() ?? 3;

            // Build a ProductModel from the formatted response
            final product = ProductModel(
              productName: json['foodName'] ?? json['productName'] ?? 'Unknown',
              productPrice: parsedPrice,
              productDiscription: json['reason'] ?? '',
              productImage: json['productImage'] ?? '',
              productId: json['productId'] ?? '',
              catagory: json['catagory'] ?? json['category'] ?? '',
              productUid: json['productOwner'] ?? '',
              productOwner: json['productOwner'] ?? '',
              location: null,
              productRating: ratingInt.toDouble(),
              averageRating: ratingInt.toDouble(),
            );

            results.add(ProductRecommendation(
              product: product,
              score: ratingInt.toDouble() * 20, // Convert 1-5 rating to 0-100 score
            ));
          }

          if (results.isNotEmpty) {
            print('AI Sync (Backend): Got ${results.length} recommendations from server.');
            return results;
          }
        }
      }
      
      print('AI Engine: Remote call failed. Falling back to local persistent engine.');
      return _localEngine.getRecommendations(query: query, topN: topN);
      
    } catch (e) {
      print('AI Engine: Remote unreachable ($e). Using local persistent engine.');
      return _localEngine.getRecommendations(query: query, topN: topN);
    }
  }

  /// Gets top-rated food items/general suggestions.
  Future<List<ProductRecommendation>> getTopRated({int topN = 15}) async {
    try {
      await _localEngine.init();
      return _localEngine.getRecommendations(topN: topN);
    } catch (e) {
      print('Top Rated Error: $e');
      return [];
    }
  }
}
