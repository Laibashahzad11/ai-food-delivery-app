import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/local_recommendation_engine.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';

class RecommendationCard extends StatelessWidget {
  final ProductRecommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = recommendation.product;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildProductImage(product.productImage, width: 70, height: 70),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${product.productOwner}',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${product.productPrice.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange),
                    ),
                    if (product.productDiscription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.productDiscription,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 3),
                      Builder(builder: (context) {
                        double raw = product.averageRating > 0
                            ? product.averageRating
                            : (product.productRating ?? 0.0);
                        int rating = raw > 0 ? raw.round().clamp(1, 5) : 3;
                        return Text(
                          '$rating / 5',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
