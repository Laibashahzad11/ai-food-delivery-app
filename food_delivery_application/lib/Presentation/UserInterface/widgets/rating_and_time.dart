import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:provider/provider.dart';

class RatingAndTimeWidget extends StatefulWidget {
  const RatingAndTimeWidget({
    required this.product,
    super.key,
  });
  final ProductModel product;

  @override
  State<RatingAndTimeWidget> createState() => _RatingAndTimeWidgetState();
}

class _RatingAndTimeWidgetState extends State<RatingAndTimeWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context
        .read<ReviewController>()
        .getReviewAverage(uid: widget.product.productUid);
  }

  @override
  Widget build(BuildContext context) {
    // Use averageRating first, fall back to productRating, then default to 3
    double rawRating = widget.product.averageRating;
    if (rawRating <= 0) {
      rawRating = widget.product.productRating ?? 0.0;
    }

    // Always show integer rating (1-5). Default = 3 if still no rating.
    final int displayRating = rawRating > 0 ? rawRating.round().clamp(1, 5) : 3;
    final bool hasRating = rawRating > 0;
    final String ratingText = displayRating.toString();

    return _buildRatingRow(ratingText, hasRating);
  }

  Widget _buildRatingRow(String ratingText, bool hasReviews) {
    return SizedBox(
      width: screenWidth(context) * 0.58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: !hasReviews ? Colors.grey : AppColor.orangeColor,
                size: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                ratingText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !hasReviews ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
