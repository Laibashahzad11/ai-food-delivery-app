import 'restaurant_model.dart';

class RecommendationResponseModel {
  final bool success;
  final String type;
  final int totalFound;
  final int showing;
  final List<RestaurantModel> recommendations;
  final Map<String, dynamic>? filtersApplied;

  RecommendationResponseModel({
    required this.success,
    required this.type,
    required this.totalFound,
    required this.showing,
    required this.recommendations,
    this.filtersApplied,
  });

  factory RecommendationResponseModel.fromJson(Map<String, dynamic> json) {
    return RecommendationResponseModel(
      success: json['success'] ?? false,
      type: json['type'] ?? '',
      totalFound: json['total_results'] ?? 0,
      showing: json['showing'] ?? 0,
      recommendations: (json['recommendations'] as List?)
              ?.map((e) => RestaurantModel.fromJson(e))
              .toList() ??
          [],
      filtersApplied: json['filters'],
    );
  }
}
