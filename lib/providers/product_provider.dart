import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/offline_cache_service.dart';

class ProductProvider with ChangeNotifier {
  Product? _currentProduct;
  bool _isLoading = false;
  String? _error;

  Product? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProductByBarcode(String barcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProduct = await ApiService.getProductByBarcode(barcode);
      if (_currentProduct == null) {
        _error = 'Product not found. Please check the barcode and try again.';
      } else {
        // Cache the product for offline access
        await OfflineCacheService.cacheLastProduct(_currentProduct!);
      }
    } catch (e) {
      _error = 'Failed to fetch product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProduct() {
    _currentProduct = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load the last viewed product from offline cache
  Future<void> loadLastProductFromCache() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProduct = await OfflineCacheService.getLastProduct();
      if (_currentProduct == null) {
        _error = 'No cached product available';
      }
    } catch (e) {
      _error = 'Failed to load cached product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
