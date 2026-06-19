import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/auth_repo.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  List<UserModel> restaurantList = [];
  bool isloading = false;

  final db = AuthDB();
  UserModel? appUser;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential> sighUpWithEmailAndPassword(
      UserModel user, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: user.email, password: password);
      appUser = user;
      await db.signUpUser(user: user, credential: userCredential);
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('error is${e.message}');
    }
  }

  Future<UserCredential> sighInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      final currentUser = db.isCurrentUser();
      log("${currentUser.toString()}tttttttttttttt");

      if (currentUser != null) {
        appUser = await db.getUserById(uid: currentUser.uid);
        if (appUser != null) {
          log("${appUser!.lat.toString()}hhhhhhhhhhhhh");
        } else {
          log("User data is null");
        }
      } else {
        log("Current user is null");
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('error is${e.message}');
    }
  }

  Future<List<UserModel>> getRestaurants(
      {required List<ProductModel> product}) async {
    try {
      restaurantList = await db.getRestaurants(product: product);
      final list = restaurantList.map((e) => e.resturantName).toList();
      log('sdasd$list');
      // categories = getUniqueCategories(productList);
      //categories.sort();
      // log(categories.toString());
      notifyListeners();

      return restaurantList;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> checkCurrentUser(BuildContext context) async {
    try {
      final isCurrentUser = db.isCurrentUser();
      if (isCurrentUser != null) {
        appUser = await db.getUserById(uid: isCurrentUser.uid);
        log(appUser!.toJson().toString());
        //notifyListeners();
        return isCurrentUser;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }

  Future<void> updateUser({required UserModel user, XFile? image}) async {
    isloading = true;
    notifyListeners();
    if (image != null) {
      final url = await db.uploadImage(
        id: user.id,
        file: image,
        ref: "users/${user.id}/${image.name}",
      );
      user.userImage = url;
      log("URL $url");
    }
    appUser = user;
    log(appUser.toString());
    notifyListeners();
    await db.updateUser(user: appUser!);
    isloading = false;
    notifyListeners();
  }

  Future<void> saveLatitude(
      {required String lat, required UserModel user}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> getLocation() async {
    //   Location location = Location();

    //   try {
    //     bool serviceEnabled = await location.serviceEnabled();
    //     if (!serviceEnabled) {
    //       serviceEnabled = await location.requestService();
    //       // if (!serviceEnabled) {
    //       //   // Location services are still not enabled
    //       //   return;
    //       // }
    //     }

    //     PermissionStatus permissionGranted = await location.hasPermission();
    //     if (permissionGranted == PermissionStatus.denied) {
    //       permissionGranted = await location.requestPermission();
    //       if (permissionGranted != PermissionStatus.granted) {
    //         // Location permission is not granted
    //         return;
    //       }
    //     }

    //     // Get current location
    //     LocationData locationData = await location.getLocation();
    //     print(
    //         'Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
    //   } catch (e) {
    //     print('Error getting location: $e');
    //   }
  }
}
