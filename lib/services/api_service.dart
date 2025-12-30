import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0';

  static Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$barcode.json'),
        headers: {'User-Agent': 'SmartFoodScanner/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          return Product.fromJson(data);
        } else {
          return null; // Product not found
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/cgi/search.pl?search_terms=$query&page_size=20&json=1',
        ),
        headers: {'User-Agent': 'SmartFoodScanner/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        return products
            .map((productData) => Product.fromJson({'product': productData}))
            .where((product) => product.name != 'Unknown Product')
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
