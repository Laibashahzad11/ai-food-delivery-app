import 'dart:convert';
import 'package:flutter/material.dart';

/// Smart image widget that handles both regular URLs and Base64 data URIs.
/// This is the single source of truth for image display in the app.
Widget buildProductImage(
  String? imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
}) {
  final fallback = placeholder ??
      Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
      );

  if (imageUrl == null || imageUrl.isEmpty) return fallback;

  // Handle Base64 data URIs with header (data:image/jpeg;base64,...)
  if (imageUrl.startsWith('data:image')) {
    try {
      final base64Str = imageUrl.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  // Handle raw Base64 strings (stored without the data: prefix)
  // A raw base64 string won't start with http and will be very long
  if (!imageUrl.startsWith('http') && imageUrl.length > 100) {
    try {
      final bytes = base64Decode(imageUrl);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  // Handle regular HTTP/HTTPS URLs
  return Image.network(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loading) =>
        loading == null ? child : fallback,
    errorBuilder: (_, __, ___) => fallback,
  );
}
