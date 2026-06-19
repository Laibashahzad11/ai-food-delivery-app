import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductDB {
  // --- Product Management ---

  Future<void> addProduct({required ProductModel product}) async {
    try {
      final newDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(product.productUid)
          .collection('products')
          .doc(product.productId);

      product.createdAt = DateTime.now().toIso8601String();
      product.orderCount = 0;
      product.popularity = 0;
      product.productRating = 0.0;
      product.totalRatingsCount = 0;
      product.totalRatingsSum = 0.0;
      product.averageRating = 0.0;
      product.isAvailable = true;

      await newDocRef.set(product.toJson());
      
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .set(product.toJson());
          
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct({required ProductModel product}) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .update(product.toJson());
          
      await FirebaseFirestore.instance
          .collection('users')
          .doc(product.productUid)
          .collection('products')
          .doc(product.productId)
          .update(product.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct({required String chefId, required String productId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(chefId)
          .collection('products')
          .doc(productId)
          .delete();
          
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- Data Sanitization ---

  List<ProductModel> _sanitizeProducts(List<ProductModel> products) {
    final seenIds = <String>{};
    final seenNames = <String>{}; 
    return products.where((p) {
      final hasImage = p.productImage.trim().isNotEmpty && 
                       p.productImage != 'null' && 
                       p.productImage != 'None' &&
                       p.productImage.length > 5;
                       
      final nameLower = p.productName.toLowerCase();
      
      // Filter out dummy/stale data from previous development phases
      final isDummy = (nameLower == 'burger' && 
                        (p.productOwner.toLowerCase() == 'foodie' || p.productOwner.toLowerCase() == 'yum'));
      final isMushroom = nameLower.contains('mushroom soup');
      final isNuggets = nameLower.contains('crispy nuggets');
      final isHotAndSour = nameLower.contains('hot & sour');
      final isOtherSoup = nameLower.contains('tomato soup'); 
      
      final uniqueKey = '${nameLower}_${p.productOwner.toLowerCase()}';
      
      final isNewId = seenIds.add(p.productId);
      final isNewNameAndOwner = seenNames.add(uniqueKey);

      return hasImage && !isDummy && !isMushroom && !isNuggets && !isHotAndSour && !isOtherSoup && isNewId && isNewNameAndOwner;
    }).toList();
  }

  // --- Data Streams & Queries ---

  Stream<List<ProductModel>> getChefProductsStream(String chefId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(chefId)
        .collection('products')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      return _sanitizeProducts(products);
    });
  }

  Future<List<ProductModel>> getChefProductsRest(String chefId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.chefProductsEndpoint(chefId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((json) => ProductModel.fromJson(json)).toList();
        return _sanitizeProducts(products);
      } else {
        throw Exception('Failed to load chef products');
      }
    } catch (e) {
      log('Error fetching chef products via REST: $e');
      return [];
    }
  }

  Stream<List<ProductModel>> getAllProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      return _sanitizeProducts(products);
    });
  }

  Stream<List<ProductModel>> getCategoryProductsStream(String category) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('catagory', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      return _sanitizeProducts(products);
    });
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      return _sanitizeProducts(products);
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getSearchProducts({required String search}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final searchProducts = querySnapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .where((product) =>
              product.productName.toLowerCase().contains(search.toLowerCase()))
          .toList();
      return _sanitizeProducts(searchProducts);
    } on FirebaseException catch (e) {
      log('Search Error: $e');
      rethrow;
    }
  }

  // --- Cart Management ---

  Future<void> addToCart(
      {required ProductModel product,
      required String totalPrice,
      required String size,
      required String uid,
      required String qunatity}) async {
    try {
      final newDocRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .doc(product.productId);
      product.quantity = qunatity;
      product.size = size;
      product.totalPrice = totalPrice;
      await newDocRef.set(product.toJson());
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  Future<void> removeItemFromCart(
      {required ProductModel productModel, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .doc(productModel.productId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getCartCount({required String uid}) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .get();
      return querySnapshot.size;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getCartTotalPrice({required String uid}) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .get();

      double totalAmount = 0.0;
      for (var doc in querySnapshot.docs) {
        final product =
            ProductModel.fromJson(doc.data() as Map<String, dynamic>);
        totalAmount += double.parse(product.totalPrice!);
      }
      return totalAmount;
    } catch (e) {
      rethrow;
    }
  }

  // --- Order & Interaction Tracking ---

  Future<void> incrementOrderCount(String productId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('products').doc(productId);
      await docRef.update({'orderCount': FieldValue.increment(1)});
    } catch (e) {
      log('Error incrementing order count: $e');
    }
  }

  Future<void> incrementPopularity(String productId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('products').doc(productId);
      await docRef.update({'popularity': FieldValue.increment(1)});
    } catch (e) {
      log('Error incrementing popularity: $e');
    }
  }

  Future<void> updateProductRating(
      {required ProductModel product, required int productRating}) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .update({'productRating': productRating});
    } catch (e) {
      rethrow;
    }
  }

  // --- Request Management ---

  Future<void> sendRequest(
      {required List<ProductModel> products,
      required String uid,
      required String address,
      required UserModel user}) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection('sendRequests')
          .doc(uid)
          .collection('sentOrders')
          .doc();

      List<Map<String, dynamic>> productsJson =
          products.map((product) {
            product.deliveryAddress = address;
            return product.toJson();
          }).toList();

      Map<String, dynamic> orderData = {
        'products': productsJson,
        'timestamp': FieldValue.serverTimestamp(),
        'docId': doc.id,
        'deliveryAddress': address,
      };
      Map<String, dynamic> userJson = user.toJson();

      await doc.set(orderData);

      for (var product in products) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(product.productUid)
            .collection('receiveOrders')
            .doc();
        product.deliveryAddress = address;
        Map<String, dynamic> productData = product.toJson();
        productData['user'] = userJson;
        productData['docId'] = userDoc.id;

        await userDoc.set(productData);
      }

      final cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(uid)
          .collection('items')
          .get();

      for (var doc in cartItemsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(
      {required ProductModel product, required UserModel user}) async {
    try {
      Map<String, dynamic> userJson = user.toJson();
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(product.productUid)
          .collection('runningOrders')
          .doc();
      Map<String, dynamic> productData = product.toJson();
      productData['user'] = userJson;
      productData['docId'] = userDoc.id;
      // Ensure address is preserved if it exists in the product model
      if (product.deliveryAddress != null) {
        productData['deliveryAddress'] = product.deliveryAddress;
      }
      await userDoc.set(productData);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ NEW Code (Replace with this)
  Future<void> completeOrder({
    required UserModel user,
    required ProductModel product,
  }) async {
    try {
      // 1. Add to history
      final historyDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .collection('history')
          .doc();  // Auto-generate ID
      await historyDoc.set(product.toJson());

      // 2. 🔴 IMPORTANT: Remove from running orders (yeh line missing thi)
      final runningOrdersQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(product.productUid)
          .collection('runningOrders')
          .where('productId', isEqualTo: product.productId)
          .get();

      for (var doc in runningOrdersQuery.docs) {
        await doc.reference.delete();
      }

      // 3. Also remove from sendRequests if exists
      final sentOrdersQuery = await FirebaseFirestore.instance
          .collection('sendRequests')
          .doc(user.id)
          .collection('sentOrders')
          .where('products', arrayContains: product.toJson())
          .get();

      for (var doc in sentOrdersQuery.docs) {
        await doc.reference.delete();
      }

      log('Order completed and moved to history for user: ${user.id}');
    } catch (e) {
      log('Error in completeOrder: $e');
      rethrow;
    }
  }

  Future<void> declineRequest({required String uid, required String docId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('receiveOrders')
          .doc(docId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromUser({required String uid, required String docId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('sendRequests')
          .doc(uid)
          .collection('sentOrders')
          .doc(docId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- Utilities ---

  Future<int> receiveOrdersLength({required String uid}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('receiveOrders')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> runningLength({required String uid}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('runningOrders')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(
      {required String id, required XFile file, required String ref}) async {
    try {
      final File imageFile = File(file.path);
      
      if (!imageFile.existsSync()) {
        throw Exception("Source file does not exist at ${file.path}");
      }

      log('Starting Base64 encoding for product image: $id');
      
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Determine mime type from extension
      final extension = file.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // Default
      if (extension == 'png') mimeType = 'image/png';
      else if (extension == 'webp') mimeType = 'image/webp';
      
      final dataUri = 'data:$mimeType;base64,$base64String';
      
      // Safety check for Firestore document size (approx 1MB limit for entire doc)
      if (dataUri.length > 800000) {
        throw Exception("Image is too large even after compression. Please choose a smaller image.");
      }

      log('Base64 encoding successful. Length: ${dataUri.length}');
      return dataUri;
    } catch (e) {
      log('Base64 Conversion Error: $e');
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'orderId': orderId ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      log('Error sending notification: $e');
    }
  }
}
