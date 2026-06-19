class ApiConfig {
  // Can be updated dynamically by ApiService
  static String baseUrl = 'http://192.168.1.10:5000';
  
  static String get searchEndpoint => '$baseUrl/search';
  static String get recommendEndpoint => '$baseUrl/recommend';
  static String get similarEndpoint => '$baseUrl/similar';
  static String get topRatedEndpoint => '$baseUrl/top-rated-simple';
  static String get uploadEndpoint => '$baseUrl/upload';
  static String get syncEndpoint => '$baseUrl/sync';
  static String get imageUrlRoot => '$baseUrl/images';

  /// Dynamically update the base URL (used by ApiService)
  static void updateBaseUrl(String newUrl) {
    if (newUrl.endsWith('/')) {
      baseUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      baseUrl = newUrl;
    }
  }

  // Chef Products
  static String chefProductsEndpoint(String chefId) => '$baseUrl/api/chef/$chefId/products';

  // Notifications
  static String get createNotificationEndpoint => '$baseUrl/api/notifications/create';
  static String getNotificationsEndpoint(String userId) => '$baseUrl/api/notifications/$userId';

  // Messaging
  static String get sendMessageEndpoint => '$baseUrl/api/messages/send';
  static String getMessagesEndpoint(String conversationId) => '$baseUrl/api/messages/$conversationId';
}
