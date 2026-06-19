import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/address_repo.dart';
import 'package:food_delivery_app_project/Domain/model/address_model.dart';

class AddressController extends ChangeNotifier {
  final db = AddressRepo();
  List<AddressModel> addressList = [];
  Future<void> addAddress({required AddressModel address}) async {
    try {
      await db.addAddress(address: address);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AddressModel>> getAdress({required String uid}) async {
    try {
      addressList = await db.getAddress(uid: uid);
      log('addresses are ${addressList.length.toString()}');
      // categories = getUniqueCategories(productList);
      //categories.sort();
      // log(categories.toString());
      notifyListeners();

      return addressList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress({required AddressModel address}) async {
    try {
      await db.deleteAddress(address: address);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
