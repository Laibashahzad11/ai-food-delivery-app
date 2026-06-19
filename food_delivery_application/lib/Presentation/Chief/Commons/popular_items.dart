import 'dart:convert' show base64Decode;
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';

class PopularItems extends StatelessWidget {
  final ProductModel product;
  const PopularItems({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        width: 150,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildProductImage(product.productImage),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  product.productName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String image) {
    if (image.startsWith('http') || image.startsWith('data:image')) {
      if (image.startsWith('data:image')) {
        // Handle Base64 images directly
        final base64String = image.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: 150,
          height: double.infinity,
        );
      }
      return Image.network(
        image,
        fit: BoxFit.cover,
        width: 150,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        width: 150,
        height: double.infinity,
      );
    }
  }
}
