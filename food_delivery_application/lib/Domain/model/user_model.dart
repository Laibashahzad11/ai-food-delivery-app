class UserModel {
  String id;
  String name;
  String email;
  String role;
  String phoneNumber;
  String bio;
  String resturantName;
  String? lat;
  String? lon;
  String? userImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.bio,
    required this.resturantName,
    this.userImage,
    this.lat,
    this.lon,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      bio: json['bio'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      resturantName: json['resturantName'] ?? '',
      role: json['role'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userImage: json['userImage'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'resturantName': resturantName,
      'userImage': userImage,
      'bio': bio,
      'lat': lat,
      'lon': lon,
    };
  }
}
