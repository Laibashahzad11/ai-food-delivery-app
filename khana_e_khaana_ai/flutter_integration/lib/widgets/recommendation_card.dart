import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RecommendationCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RecommendationCard({
    Key? key,
    required this.restaurant,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on match score if available
    Color scoreColor = Colors.grey;
    if (restaurant.matchScore != null) {
      if (restaurant.matchScore! >= 80) scoreColor = Colors.green;
      else if (restaurant.matchScore! >= 60) scoreColor = Colors.orange;
      else scoreColor = Colors.red;
    } else if (restaurant.similarityScore != null) {
      if (restaurant.similarityScore! >= 80) scoreColor = Colors.green;
      else if (restaurant.similarityScore! >= 60) scoreColor = Colors.orange;
      else scoreColor = Colors.red;
    }

    // Determine relevant score to show
    final score = restaurant.matchScore ?? restaurant.similarityScore;
    final scoreLabel = restaurant.matchScore != null ? 'Match' : 'Similarity';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scoreColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: scoreColor),
                          const SizedBox(width: 4),
                          Text(
                            '$scoreLabel: ${score.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.city,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.restaurant_menu, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant.cuisines,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatBadge(
                    context,
                    Icons.star_rounded,
                    restaurant.rating.toString(),
                    Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    context,
                    Icons.comment,
                    '${restaurant.reviewsCount} reviews',
                    Colors.blueGrey,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    context,
                    Icons.attach_money,
                    restaurant.priceCategory.toUpperCase(),
                    Colors.green[700]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
