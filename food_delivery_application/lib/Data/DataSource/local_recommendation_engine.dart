import 'dart:math';
import 'dart:convert';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalRecommendationEngine {
  // Singleton pattern
  static final LocalRecommendationEngine _instance = LocalRecommendationEngine._internal();
  factory LocalRecommendationEngine() => _instance;
  LocalRecommendationEngine._internal();

  List<ProductModel> _allProducts = [];
  Database? _database;
  bool _isInitialized = false;
  
  /// Initialize the engine and load data from disk
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'ai_recommendations.db');
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              data TEXT
            )
          ''');
        },
      );
      
      await _loadFromDisk();
      _isInitialized = true;
      print('AI Engine: Initialized with ${_allProducts.length} persistent products.');
    } catch (e) {
      print('AI Engine Init Error: $e');
    }
  }

  Future<void> _loadFromDisk() async {
    if (_database == null) return;
    
    try {
      final List<Map<String, dynamic>> maps = await _database!.query('products');
      _allProducts = maps.map((m) {
        return ProductModel.fromJson(jsonDecode(m['data'] as String));
      }).toList();
    } catch (e) {
      print('AI Engine Load Error: $e');
    }
  }

  /// Update the live data pool and persist to disk
  Future<void> updateData(List<ProductModel> products) async {
    _allProducts = products;
    print('AI Engine: ${_allProducts.length} products loaded into memory.');
    
    if (_database == null) await init();
    
    try {
      final batch = _database!.batch();
      
      // Clear old data for a fresh sync
      batch.delete('products');
      
      for (var product in products) {
        batch.insert('products', {
          'id': product.productId,
          'data': jsonEncode(product.toJson())
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      
      await batch.commit(noResult: true);
      print('AI Engine: Successfully persisted ${products.length} products to disk.');
    } catch (e) {
      print('AI Engine Save Error: $e');
    }
  }

  /// Recommend products based on a query or user context with STRICT ranking
  List<ProductRecommendation> getRecommendations({String? query, String? preferredCategory, int topN = 10}) {
    // If not initialized, it returns empty (but main.dart will trigger init)
    if (_allProducts.isEmpty) return [];

    List<ProductRecommendation> recommendations = [];
    bool dishKeywordDetected = false;
    List<String> dishKeywords = [];

    // Analyze query for potential dish keywords
    if (query != null && query.isNotEmpty) {
      List<String> words = query.toLowerCase().split(RegExp(r'[\s\-,\.]+'));
      const stopWords = {'i', 'want', 'some', 'the', 'is', 'for', 'me', 'show', 'find', 'get', 'hungry', 'food', 'something', 'cheap', 'best', 'sasta', 'affordable', 'and', 'with', 'extra', 'was', 'were', 'had', 'suggest', 'give', 'please', 'tell', 'suggest me', 'can', 'you', 'u'};
      
      // Preference keywords should NOT be used for strict dish filtering
      const preferenceKeywords = {'spicy', 'hot', 'sweet', 'fresh', 'delicious', 'healthy', 'light', 'heavy', 'crispy', 'tasty', 'masala', 'masaly', 'dar', 'sauce', 'white'};
      
      dishKeywords = words.where((w) {
        return w.length >= 3 && !stopWords.contains(w) && !preferenceKeywords.contains(w);
      }).toList();
      
      // Specifically add 'wrap' if present (it's 4 chars, but let's be sure)
      if (query.toLowerCase().contains('wrap')) {
        if (!dishKeywords.contains('wrap')) dishKeywords.add('wrap');
      }
      if (query.toLowerCase().contains('roll')) {
        if (!dishKeywords.contains('roll')) dishKeywords.add('roll');
      }

      dishKeywordDetected = dishKeywords.isNotEmpty;
    }

    for (var product in _allProducts) {
      double ratingScore = (product.productRating?.toDouble() ?? 0.0) / 5.0;
      double relevanceModifier = 1.0;
      bool matches = false;
      bool dishMatches = false;

      String name = product.productName.toLowerCase();
      String cat = product.catagory.toLowerCase();
      String desc = product.productDiscription.toLowerCase();

      if (query != null && query.isNotEmpty) {
        // 1. Check for specific dish matches with fuzzy support
        for (var dkw in dishKeywords) {
          // Direct or fuzzy prefix match (e.g. 'biry' matches 'biryani' or 'biyani')
          bool direct = name.contains(dkw) || cat.contains(dkw) || desc.contains(dkw);
          bool fuzzy = (dkw.length > 4 && (name.contains(dkw.substring(0, 4)) || cat.contains(dkw.substring(0, 4))));
          
          if (direct || fuzzy) {
            relevanceModifier *= 5.0;
            dishMatches = true;
            matches = true;
          }
        }

        // 2. Check for general keywords/vibe
        if (!dishMatches) {
          // General vibe or keyword matching...
          if (name.contains(query.toLowerCase()) || cat.contains(query.toLowerCase())) {
            relevanceModifier *= 1.2;
            matches = true;
          }
        }
      } else if (preferredCategory != null && product.catagory.toLowerCase() == preferredCategory.toLowerCase()) {
        relevanceModifier = 1.2;
        matches = true;
      } else if (query == null && preferredCategory == null) {
        matches = true; // General recommendations
      }

      // STRICT FILTER: If a dish was requested, ONLY show matching dishes
      if (dishKeywordDetected && !dishMatches) {
        continue;
      }
      
      // If no general match either, skip
      if (!matches && query != null) {
        continue;
      }

      // Scoring: (Base 1.0 + Rating 0.0-1.0) * Relevance
      // This ensures even 0-rated products have a score
      double score = (1.0 + ratingScore) * relevanceModifier * 50.0;

      recommendations.add(ProductRecommendation(
        product: product,
        score: score,
      ));
    }

    if (recommendations.isEmpty && _allProducts.isNotEmpty && (query != null || preferredCategory != null)) {
      // If a specific dish was requested but not found, do NOT show everything else.
      // Returning empty allows the UI to show "No recommendations found".
      return []; 
    }

    // Sort based on intent
    bool isCheapQuery = query?.toLowerCase().contains('cheap') ?? false;
    bool isSastaQuery = query?.toLowerCase().contains('sasta') ?? false;
    bool isExpensiveQuery = query?.toLowerCase().contains('expensive') ?? false;
    bool isMehngaQuery = query?.toLowerCase().contains('mehnga') ?? false;

    recommendations.sort((a, b) {
      if (isCheapQuery || isSastaQuery) {
        // Price First (Low to High)
        int cmp = a.product.productPrice.compareTo(b.product.productPrice);
        if (cmp != 0) return cmp;
        return (b.product.productRating ?? 0.0).compareTo(a.product.productRating ?? 0.0);
      } else if (isExpensiveQuery || isMehngaQuery) {
        // Price First (High to Low)
        int cmp = b.product.productPrice.compareTo(a.product.productPrice);
        if (cmp != 0) return cmp;
        return (b.product.productRating ?? 0.0).compareTo(a.product.productRating ?? 0.0);
      } else {
        // Relevance/Rating First
        if ((b.score - a.score).abs() > 5.0) {
          return b.score.compareTo(a.score);
        }
        int priceCmp = a.product.productPrice.compareTo(b.product.productPrice);
        if (priceCmp != 0) return priceCmp;
        return (b.product.productRating ?? 0.0).compareTo(a.product.productRating ?? 0.0);
      }
    });

    return recommendations.take(topN).toList();
  }
}

class ProductRecommendation {
  final ProductModel product;
  final double score;

  ProductRecommendation({required this.product, required this.score});
}
