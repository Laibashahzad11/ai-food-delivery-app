class AddressModel {
  final String address;
  final String street;
  final String postalCode;
  final String apartment;
  final String label;
  final String uid;
  String? docId;

  AddressModel({
    required this.address,
    required this.apartment,
    required this.label,
    required this.postalCode,
    required this.street,
    required this.uid,
    this.docId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address: json['address'],
      uid: json['uid'],
      docId: json['docId'],
      apartment: json['apartment'],
      label: json['label'],
      postalCode: json['postalCode'],
      street: json['street'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "uid": uid,
      "docId": docId,
      "apartment": apartment,
      "label": label,
      "postalCode": postalCode,
      "street": street,
    };
  }
}
