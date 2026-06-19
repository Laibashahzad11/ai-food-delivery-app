import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Domain/model/address_model.dart';

class AddressRepo {
  Future<void> addAddress({required AddressModel address}) async {
    try {
      print('1');
      final newDoc = FirebaseFirestore.instance
          .collection('addresses')
          .doc(address.uid)
          .collection('adress')
          .doc();
      address.docId = newDoc.id;
      newDoc.set(address.toJson());
      print('2');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AddressModel>> getAddress({required String uid}) async {
    try {
      final addressRef = FirebaseFirestore.instance
          .collection('addresses')
          .doc(uid)
          .collection('adress');
      final querySnapshot = await addressRef.get();

      final addresses = querySnapshot.docs
          .map((doc) => AddressModel.fromJson(doc.data()))
          .toList();
      log(addresses.length.toString());

      return addresses;
    } on FirebaseException catch (e) {
      // Handle Firebase errors appropriately (e.g., logging, user notifications)
      rethrow;
    }
  }

  Future<void> deleteAddress({required AddressModel address}) async {
    try {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(address.uid)
          .collection('adress')
          .doc(address.docId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
