class Product {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final NutritionFacts nutritionFacts;
  final List<String> ingredients;
  final String? allergens;

  Product({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.nutritionFacts,
    required this.ingredients,
    this.allergens,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final nutriments = product['nutriments'] ?? {};

    return Product(
      barcode: product['code'] ?? '',
      name: product['product_name'] ?? 'Unknown Product',
      brand: product['brands'] ?? 'Unknown Brand',
      imageUrl: product['image_url'],
      nutritionFacts: NutritionFacts.fromJson(nutriments),
      ingredients: _parseIngredients(product['ingredients_text']),
      allergens: product['allergens'],
    );
  }

  static List<String> _parseIngredients(String? ingredientsText) {
    if (ingredientsText == null || ingredientsText.isEmpty) {
      return [];
    }
    return ingredientsText.split(',').map((e) => e.trim()).toList();
  }
}

class NutritionFacts {
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? sugars;
  final double? fat;
  final double? saturatedFat;
  final double? fiber;
  final double? salt;
  final double? sodium;

  NutritionFacts({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.fiber,
    this.salt,
    this.sodium,
  });

  factory NutritionFacts.fromJson(Map<String, dynamic> json) {
    return NutritionFacts(
      calories: _parseDouble(json['energy-kcal_100g']),
      protein: _parseDouble(json['proteins_100g']),
      carbohydrates: _parseDouble(json['carbohydrates_100g']),
      sugars: _parseDouble(json['sugars_100g']),
      fat: _parseDouble(json['fat_100g']),
      saturatedFat: _parseDouble(json['saturated-fat_100g']),
      fiber: _parseDouble(json['fiber_100g']),
      salt: _parseDouble(json['salt_100g']),
      sodium: _parseDouble(json['sodium_100g']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

