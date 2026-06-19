class ProductModel {
  String productName;
  double productPrice;
  String productDiscription;
  String productImage;
  String productId;
  String catagory;
  String productUid;
  String productOwner;
  String? totalPrice;
  String? size;
  String? quantity;
  double? productRating;
  UserLocation? location;
  int orderCount;
  int popularity;
  String? createdAt;
  int totalRatingsCount;
  double totalRatingsSum;
  double averageRating;
  bool isAvailable;
  String? imageBase64;

  String? deliveryAddress;

  ProductModel({
    required this.productDiscription,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.productId,
    required this.catagory,
    required this.productUid,
    required this.productOwner,
    this.quantity,
    this.size,
    this.productRating = 0.0,
    this.totalPrice,
    required this.location,
    this.orderCount = 0,
    this.popularity = 0,
    this.createdAt,
    this.totalRatingsCount = 0,
    this.totalRatingsSum = 0.0,
    this.averageRating = 0.0,
    this.isAvailable = true,
    this.imageBase64,
    this.deliveryAddress,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        catagory: json['catagory'] ?? 'Other',
        productId: json['productId'] ?? '',
        productDiscription: json['productDiscription'] ?? '',
        productImage: json['productImage'] ?? '',
        productName: json['productName'] ?? 'No Name',
        productPrice: (json['productPrice'] is String) 
            ? double.tryParse(json['productPrice']) ?? 0.0 
            : (json['productPrice']?.toDouble() ?? 0.0),
        productUid: json['productUid'] ?? '',
        productOwner: json['productOwner'] ?? '',
        quantity: json['quantity'],
        productRating: (json['productRating'] is int) 
            ? (json['productRating'] as int).toDouble() 
            : json['productRating']?.toDouble(),
        size: json['size'],
        totalPrice: json['totalPrice'],
        orderCount: json['orderCount'] ?? 0,
        popularity: json['popularity'] ?? 0,
        createdAt: json['createdAt'],
        totalRatingsCount: json['totalRatingsCount'] ?? 0,
        totalRatingsSum: (json['totalRatingsSum']?.toDouble() ?? 0.0),
        averageRating: (json['averageRating']?.toDouble() ?? 0.0),
        isAvailable: json['isAvailable'] ?? true,
        imageBase64: json['imageBase64'],
        deliveryAddress: json['deliveryAddress'],
        location: (json['location'] != null && json['location'] is Map<String, dynamic>)
            ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'productDiscription': productDiscription,
      'catagory': catagory,
      'productImage': productImage,
      'productName': productName,
      'productPrice': productPrice,
      'productId': productId,
      'productUid': productUid,
      'productOwner': productOwner,
      'size': size,
      'productRating': productRating,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderCount': orderCount,
      'popularity': popularity,
      'createdAt': createdAt,
      'totalRatingsCount': totalRatingsCount,
      'totalRatingsSum': totalRatingsSum,
      'averageRating': averageRating,
      'isAvailable': isAvailable,
      'imageBase64': imageBase64,
      'deliveryAddress': deliveryAddress,
      'location': location?.json()
    };
  }
}

class UserLocation {
  double? lon;
  double? lat;

  UserLocation({
    required this.lat,
    required this.lon,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      lat: json['lat'],
      lon: json['lon'],
    );
  }

  Map<String, dynamic> json() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}
