import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'dart:developer';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetches the dynamically reported Backend URL from Firestore
  Future<void> initializeDynamicIp() async {
    try {
      log('ApiService: Fetching backend IP from Firestore...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('system_config')
          .doc('backend_api')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('baseUrl')) {
          final fetchedUrl = data['baseUrl'] as String;
          ApiConfig.updateBaseUrl(fetchedUrl);
          log('ApiService: Successfully connected to AI Backend at $fetchedUrl');
        }
      } else {
        log('ApiService: No backend configuration found in Firestore. Using default.');
      }
    } catch (e) {
      log('ApiService Error: Failed to fetch backend IP: $e');
      // Continues with default IP from ApiConfig
    }
  }
}
