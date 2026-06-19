import 'restaurant.dart';

class RecommendationResponse {
  final bool success;
  final String type;
  final int totalFound;
  final int showing;
  final List<Restaurant> recommendations;
  final Map<String, dynamic>? filtersApplied;

  RecommendationResponse({
    required this.success,
    required this.type,
    required this.totalFound,
    required this.showing,
    required this.recommendations,
    this.filtersApplied,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      success: json['success'] ?? false,
      type: json['type'] ?? '',
      totalFound: json['total_results'] ?? 0, // Note: API uses 'total_results' in some endpoints, 'total_found' in others, handling mismatch
      showing: json['showing'] ?? 0,
      recommendations: (json['recommendations'] as List?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      filtersApplied: json['filters'],
    );
  }
}
