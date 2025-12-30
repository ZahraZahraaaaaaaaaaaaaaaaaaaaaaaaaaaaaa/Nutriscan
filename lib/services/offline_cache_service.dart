import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class OfflineCacheService {
  static const String _lastProductKey = 'last_viewed_product';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  /// Cache the last viewed product for offline access
  static Future<void> cacheLastProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productJson = {
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
      };

      await prefs.setString(_lastProductKey, json.encode(productJson));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get the last viewed product from cache if still valid
  static Future<Product?> getLastProduct() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productJsonString = prefs.getString(_lastProductKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (productJsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        // Cache expired, clear it
        await clearCache();
        return null;
      }

      final productJson = json.decode(productJsonString);
      return Product.fromJson({'product': productJson});
    } catch (e) {
      return null;
    }
  }

  /// Clear the offline cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastProductKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if there's a valid cached product
  static Future<bool> hasValidCache() async {
    final product = await getLastProduct();
    return product != null;
  }

  /// Get cache age in hours
  static Future<int?> getCacheAgeInHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      return now.difference(cacheTime).inHours;
    } catch (e) {
      return null;
    }
  }
}
