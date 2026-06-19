import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/notification_repo.dart';
import 'package:food_delivery_app_project/Domain/model/notification_model.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepo _repo = NotificationRepo();
  List<NotificationModel> notifications = [];
  bool isLoading = false;

  Future<void> fetchNotifications(String userId) async {
    isLoading = true;
    notifyListeners();
    try {
      notifications = await _repo.getNotifications(userId);
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    final success = await _repo.createNotification(notification);
    if (success) {
      notifications.insert(0, notification);
      notifyListeners();
    }
  }
}
