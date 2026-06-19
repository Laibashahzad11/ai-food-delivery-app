import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'package:food_delivery_app_project/Domain/model/notification_model.dart';

class NotificationRepo {
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getNotificationsEndpoint(userId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<bool> createNotification(NotificationModel notification) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createNotificationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(notification.toJson()),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }
}
