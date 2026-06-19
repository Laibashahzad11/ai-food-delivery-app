import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/recommendation_repo.dart';
import 'package:food_delivery_app_project/Data/DataSource/local_recommendation_engine.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/individual_food_details.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/recommendation_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RecommendationRepo _repo = RecommendationRepo();
  
  bool _isLoading = false;
  List<ProductRecommendation> _recommendations = [];
  String _errorMessage = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final results = await _repo.searchFood(_searchController.text);
      setState(() {
        _recommendations = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Suggestions'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dishes...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.deepOrangeAccent),
            SizedBox(height: 24),
            Text(
              'How can I help you?',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Search for your favorite food or cravings!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    // UI-level safety check - relaxed to allow products even if images are being synced
    final validRecommendations = _recommendations.where((rec) {
      final p = rec.product;
      // Only filter out if it's truly broken/empty
      return p.productName.isNotEmpty && p.productPrice > 0;
    }).toList();
    
    if (validRecommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No matching food found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for something else, like "spicy burger" or "cheap pizza".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: validRecommendations.length,
      itemBuilder: (context, index) {
        final rec = validRecommendations[index];
        return RecommendationCard(
          recommendation: rec,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndividualFoodDetails(product: rec.product),
              ),
            );
          },
        );
      },
    );
  }
}
