import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../services/cloud_repository.dart';

class HistoryProvider with ChangeNotifier {
  List<Product> _history = [];
  List<Product> _favorites = [];
  static const int maxHistorySize = 20;
  final CloudRepository _cloudRepository = CloudRepository();

  List<Product> get history => _history;
  List<Product> get favorites => _favorites;
  List<String> get favoriteBarcodes =>
      _favorites.map((p) => p.barcode).toList();

  HistoryProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load history
      final historyJson = prefs.getString('product_history');
      if (historyJson != null) {
        final historyData = json.decode(historyJson) as List;
        _history = historyData
            .map((json) => Product.fromJson({'product': json}))
            .toList();
      }

      // Load favorites
      final favoritesJson = prefs.getString('favorite_products');
      if (favoritesJson != null) {
        final favoritesData = json.decode(favoritesJson) as List;
        _favorites = favoritesData
            .map((json) => Product.fromJson({'product': json}))
            .toList();
      }

      // If logged in, try to sync favorites from cloud
      if (_cloudRepository.isLoggedIn) {
        final cloudFavorites = await _cloudRepository.loadFavorites();
        if (cloudFavorites != null && cloudFavorites.isNotEmpty) {
          // Merge cloud favorites with local (keep both)
          final localBarcodes = _favorites.map((p) => p.barcode).toSet();
          for (final barcode in cloudFavorites) {
            if (!localBarcodes.contains(barcode)) {
              // Would need to fetch product data, but for now just merge barcodes
              // Full implementation would fetch product details
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addToHistory(Product product) async {
    // Remove if already exists
    _history.removeWhere((p) => p.barcode == product.barcode);

    // Add to beginning
    _history.insert(0, product);

    // Limit size
    if (_history.length > maxHistorySize) {
      _history = _history.take(maxHistorySize).toList();
    }

    notifyListeners();
    await _saveHistory();

    // Sync to cloud if logged in
    if (_cloudRepository.isLoggedIn) {
      await _cloudRepository.saveRecents(_history);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final existingIndex = _favorites.indexWhere(
      (p) => p.barcode == product.barcode,
    );

    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(product);
    }

    notifyListeners();
    await _saveFavorites();

    // Sync to cloud if logged in
    if (_cloudRepository.isLoggedIn) {
      await _cloudRepository.saveFavorites(favoriteBarcodes);
    }
  }

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.barcode == product.barcode);
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();
    await _saveFavorites();

    // Sync to cloud if logged in
    if (_cloudRepository.isLoggedIn) {
      await _cloudRepository.saveFavorites([]);
    }
  }

  // Sync data to cloud (called on sign-in)
  Future<void> syncToCloud() async {
    if (_cloudRepository.isLoggedIn) {
      await _cloudRepository.saveRecents(_history);
      await _cloudRepository.saveFavorites(favoriteBarcodes);
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyData = _history
          .map(
            (product) => {
              'barcode': product.barcode,
              'name': product.name,
              'brand': product.brand,
              'imageUrl': product.imageUrl,
              'nutritionFacts': {
                'calories': product.nutritionFacts.calories,
                'protein': product.nutritionFacts.protein,
                'carbohydrates': product.nutritionFacts.carbohydrates,
                'sugars': product.nutritionFacts.sugars,
                'fat': product.nutritionFacts.fat,
                'saturatedFat': product.nutritionFacts.saturatedFat,
                'fiber': product.nutritionFacts.fiber,
                'salt': product.nutritionFacts.salt,
                'sodium': product.nutritionFacts.sodium,
              },
              'ingredients': product.ingredients,
              'allergens': product.allergens,
            },
          )
          .toList();

      await prefs.setString('product_history', json.encode(historyData));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = _favorites
          .map(
            (product) => {
              'barcode': product.barcode,
              'name': product.name,
              'brand': product.brand,
              'imageUrl': product.imageUrl,
              'nutritionFacts': {
                'calories': product.nutritionFacts.calories,
                'protein': product.nutritionFacts.protein,
                'carbohydrates': product.nutritionFacts.carbohydrates,
                'sugars': product.nutritionFacts.sugars,
                'fat': product.nutritionFacts.fat,
                'saturatedFat': product.nutritionFacts.saturatedFat,
                'fiber': product.nutritionFacts.fiber,
                'salt': product.nutritionFacts.salt,
                'sodium': product.nutritionFacts.sodium,
              },
              'ingredients': product.ingredients,
              'allergens': product.allergens,
            },
          )
          .toList();

      await prefs.setString('favorite_products', json.encode(favoritesData));
    } catch (e) {
      // Handle error silently
    }
  }
}
