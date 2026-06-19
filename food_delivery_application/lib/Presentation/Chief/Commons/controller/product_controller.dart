import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/product_repo.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/recommendation_repo.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/review_repo.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends ChangeNotifier {
  final db = ProductDB();
  final aiRepo = RecommendationRepo();
  final reviewDb = ReviewRepo();

  List<ProductModel> productList = [];
  List<ProductModel> requestList = [];
  List<ProductModel> searchProductList = [];
  List<String> categories = [];
  List<ProductModel> pizzaList = [];
  int myCartLength = 0;
  double myCartTotalPrice = 0;
  int receiveLength = 0;
  int runningLength = 0;
  bool isloading = false;

  Future<void> addProduct(ProductModel product, XFile? image) async {
    try {
      if (image != null) {
        final base64Data = await db.uploadImage(
            id: product.productId,
            file: image,
            ref: "product_images/${product.productUid}/${product.productId}_${image.name}");
        product.imageBase64 = base64Data;
        product.productImage = base64Data; // Setting both for now to avoid breaking UI that reads productImage
        log("Base64 Generated and stored in imageBase64/productImage fields.");
      }
      await db.addProduct(product: product);
      productList.add(product);
      
      // Auto-sync with AI engine after adding new product
      await syncDataWithAI();

      log(productList.length.toString());
      notifyListeners();
    } on Exception catch (e) {
      throw Exception('error is${e.toString()}');
    }
  }

  Future<void> addToCart(
      {required ProductModel product,
      required String totalPrice,
      required String size,
      required String uid,
      required String qunatity}) async {
    try {
      await db.addToCart(
          product: product,
          totalPrice: totalPrice,
          size: size,
          uid: uid,
          qunatity: qunatity);
    } catch (e) {}
  }

  Future<void> removeItemFromCart(
      {required ProductModel productModel, required String uid}) async {
    try {
      await db.removeItemFromCart(productModel: productModel, uid: uid);
      await getCartTotalPrice(uid: uid);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> removeFromUser(
      {required ProductModel product,
      required String uid,
      required String docId}) async {
    try {
      await db.removeFromUser(uid: uid, docId: docId);
      // receiveLength = await db.receiveOrdersLength(uid: uid);
      notifyListeners();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getCartCount({required String uid}) async {
    try {
      myCartLength = await db.getCartCount(uid: uid);
      print(myCartLength);
      notifyListeners();
      return myCartLength;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getCartTotalPrice({required String uid}) async {
    try {
      print('hi');
      myCartTotalPrice = await db.getCartTotalPrice(uid: uid);
      log('kamal${myCartTotalPrice.toString()}');
      notifyListeners();
      return myCartTotalPrice;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateProduct(ProductModel product) async {
    try {
      await db.updateProduct(product: product);
      
      // Sync with AI after update
      await syncDataWithAI();
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String chefId, String productId) async {
    try {
      await db.deleteProduct(chefId: chefId, productId: productId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Real-time stream for a specific chef's products
  Stream<List<ProductModel>> chefProductsStream(String chefId) {
    return db.getChefProductsStream(chefId);
  }

  /// Real-time stream for all products (User side)
  Stream<List<ProductModel>> allProductsStream() {
    return db.getAllProductsStream();
  }

  /// Real-time stream for products by category
  Stream<List<ProductModel>> categoryProductsStream(String category) {
    return db.getCategoryProductsStream(category);
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final allProducts = await db.getProducts();
      
      // Removed dummy data filtering as requested. 
      // Only show real products.
      productList = allProducts;
      
      categories = getUniqueCategories(productList);
      
      if (productList.isNotEmpty) {
        await syncDataWithAI();
      }
      
      notifyListeners();

      return productList;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getChefProducts(String chefId) async {
    try {
      isloading = true;
      notifyListeners();
      
      final products = await db.getChefProductsRest(chefId);
      productList = products;
      
      isloading = false;
      notifyListeners();
      return productList;
    } catch (e) {
      isloading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendOrderRequest(
      {required List<ProductModel> products,
      required String uid,
      required String address,
      required UserModel user}) async {
    try {
      await db.sendRequest(products: products, uid: uid, user: user, address: address);
      
      // Increment order count for each product
      for (var product in products) {
        await db.incrementOrderCount(product.productId);
      }
      
      // Send real notification to Chef
      await db.sendNotification(
        userId: uid,
        title: 'New Order Received',
        body: 'New order received from ${user.name}',
        type: 'new_order',
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(
      {required ProductModel product, required UserModel user}) async {
    try {
      await db.acceptRequest(product: product, user: user);
      runningLength = await db.runningLength(uid: product.productUid);
      
      // Send real notification to User
      await db.sendNotification(
        userId: user.id,
        title: 'Order Accepted',
        body: 'Your order has been accepted',
        type: 'order_accepted',
        orderId: product.productId,
      );

      log(runningLength.toString());
      notifyListeners();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> completeOrder(
      {required ProductModel product, required UserModel user}) async {
    try {
      await db.completeOrder(user: user, product: product);

      // Send notification to user
      await db.sendNotification(
        userId: user.id,
        title: 'Order Delivered',
        body: 'Your order has been delivered successfully!',
        type: 'order_delivered',
        orderId: product.productId,
      );

      // 🔴 IMPORTANT: Refresh running length
      runningLength = await db.runningLength(uid: product.productUid);

      // 🔴 IMPORTANT: Refresh receive length
      receiveLength = await db.receiveOrdersLength(uid: product.productUid);

      notifyListeners();

      log('Order completed: ${product.productName} moved to history');
    } catch (e) {
      log('Error completing order: $e');
      rethrow;
    }
  }
  Future<void> updateProductRating(String productId, int newRating) async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final data = productDoc.data()!;
        final currentTotal = data['totalRatingsCount'] ?? 0;
        final currentSum = (data['totalRatingsSum'] ?? 0).toDouble();

        final newTotal = currentTotal + 1;
        final newSum = currentSum + newRating;
        final newAverage = newSum / newTotal;

        await FirebaseFirestore.instance.collection('products').doc(productId).update({
          'totalRatingsCount': newTotal,
          'totalRatingsSum': newSum,
          'averageRating': newAverage,
          'productRating': newAverage, // for backward compatibility
        });

        // Update local list
        final index = productList.indexWhere((p) => p.productId == productId);
        if (index != -1) {
          productList[index].totalRatingsCount = newTotal;
          productList[index].totalRatingsSum = newSum;
          productList[index].averageRating = newAverage;
        }

        notifyListeners();
        log('Product rating updated: $productId -> $newAverage ($newTotal ratings)');
      }
    } catch (e) {
      log('Error updating product rating: $e');
      rethrow;
    }
  }

  Future<void> declineRequest(
      {required ProductModel product,
      required String uid,
      required String docId}) async {
    try {
      await db.declineRequest(uid: uid, docId: docId);
      receiveLength = await db.receiveOrdersLength(uid: uid);
      
      // Note: We might want to send a notification to the user here too
      // User data is not directly in the params but we can find it
      
      notifyListeners();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> syncDataWithAI() async {
    try {
      if (productList.isNotEmpty) {
        // Parallelize rating checks to avoid sequential bottlenecks
        await Future.wait(productList.map((product) async {
          if (product.averageRating == 0) {
            try {
              final avg = await reviewDb.getReviewAverage(uid: product.productId);
              if (avg > 0) {
                product.averageRating = avg;
                product.productRating = avg;
                // Lazy migration - actually we don't need syncProductRating anymore
                // as it's handled atomically in ReviewRepo
              } else {
                product.averageRating = 0.0;
              }
            } catch (e) {
              product.averageRating = 0;
            }
          }
        }));
        
        await aiRepo.syncData(productList);
        log('AI Sync: Successfully synchronized ${productList.length} products in parallel.');
      }
    } catch (e) {
      log('Failed to sync with AI: $e');
    }
  }

  Future<List<ProductModel>> getSearchProducts({required String search, bool sortByRating = true}) async {
    try {
      isloading = true;
      notifyListeners();

      Query query = FirebaseFirestore.instance.collection('products');

      if (search.trim().isNotEmpty) {
        query = query
            .where('productName', isGreaterThanOrEqualTo: search)
            .where('productName', isLessThan: search + 'z');
      }

      final snapshot = await query.get();
      var products = snapshot.docs
          .map((e) => ProductModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();

      // Sort by rating if requested
      if (sortByRating) {
        products.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      }

      searchProductList = products;
      isloading = false;
      notifyListeners();

      return searchProductList;
    } catch (e) {
      isloading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<String> getUniqueCategories(List<ProductModel> products) {
    return products.map((product) => product.catagory).toSet().toList();
  }

  Future<int> receiveOrdersLength({required String uid}) async {
    try {
      receiveLength = await db.receiveOrdersLength(uid: uid);
      log(receiveLength.toString());
      notifyListeners();
      return receiveLength;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> runningOrdersLength({required String uid}) async {
    try {
      isloading = true;
      notifyListeners();
      runningLength = await db.runningLength(uid: uid);
      log(runningLength.toString());
      isloading = false;
      notifyListeners();
      return runningLength;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> trackProductClick(String productId) async {
    try {
      await db.incrementPopularity(productId);
    } catch (e) {
      log('Error tracking product click: $e');
    }
  }

}
