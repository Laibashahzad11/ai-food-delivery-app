import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthDB {
  Future<void> signUpUser(
      {required UserModel user, required UserCredential credential}) async {
    try {
      print('i am here');
      user.id = credential.user!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser({required UserModel user, String? receiver}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update(user.toJson());

    final chatDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('chats')
        .get();

    final ids = chatDocs.docs.map((e) => e.id);
    log(ids.toString());
    for (final id in ids) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('chats')
          .doc(user.id)
          .update(user.toJson());
    }

    // Update user information in each chat document
    // for (var chatDoc in chatDocs.docs) {
    //   if (user.userImage != chatDoc.data()['userImage']) {
    //     await chatDoc.reference.update(user.toJson());
    //   }
    // }
  }

  Future<UserModel?> getUserById({required String uid}) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = snapshot.data();
    if (data != null) {
      return UserModel.fromJson(data);
    } else {
      return null; // Return null if data is null
    }
  }

  Future<List<UserModel>> getRestaurants(
      {required List<ProductModel> product}) async {
    try {
      // Get unique IDs to reduce count and improve query efficiency
      final productIds = product.map((e) => e.productUid).toSet().toList();
      
      if (productIds.isEmpty) return [];

      List<UserModel> restaurants = [];
      
      // Firestore 'whereIn' supports max 30 elements. Batch the requests.
      for (var i = 0; i < productIds.length; i += 30) {
        final end = (i + 30 < productIds.length) ? i + 30 : productIds.length;
        final chunk = productIds.sublist(i, end);
        
        final productsRef = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Chef')
            .where('id', whereIn: chunk);
            
        final querySnapshot = await productsRef.get();
        
        restaurants.addAll(querySnapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList());
      }

      log('hiiiiiiiiiiiiiii${restaurants.length.toString()}');
      return restaurants;
    } on FirebaseException catch (e) {
      // Handle Firebase errors appropriately (e.g., logging, user notifications)
      rethrow;
    }
  }

  User? isCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Stores user profile photo as Base64 data URI in Firestore.
  /// 100% Free, works offline, no external accounts required.
  Future<String> uploadImage(
      {required String id, required XFile file, required String ref}) async {
    try {
      log('🔄 Auth: Encoding profile photo to Base64...');
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64String';
      log('✅ Auth: Profile photo encoded (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
      return dataUri;
    } catch (e) {
      log('❌ Auth: Upload Error: $e');
      rethrow;
    }
  }
}
