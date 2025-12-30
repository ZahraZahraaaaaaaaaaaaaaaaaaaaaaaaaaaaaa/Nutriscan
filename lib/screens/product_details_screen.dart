import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/product_provider.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/services/health_analyzer.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, UserProfileProvider, HistoryProvider>(
      builder:
          (context, productProvider, profileProvider, historyProvider, child) {
        final product = productProvider.currentProduct;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('No product data available')),
          );
        }

        final healthVerdict = HealthAnalyzer.analyzeProduct(
          product,
          profileProvider.profile,
        );
        final isFavorite = historyProvider.isFavorite(product);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppTheme.primaryTheme : null,
                ),
                onPressed: () {
                  historyProvider.toggleFavorite(product);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                _buildProductHeader(context, product),
                const SizedBox(height: 24),

                // Health Verdict
                _buildHealthVerdict(context, healthVerdict),
                const SizedBox(height: 24),

                // Personalized Recommendation
                if (healthVerdict.personalizedRecommendation != null) ...[
                  _buildPersonalizedRecommendation(
                    context,
                    healthVerdict.personalizedRecommendation!,
                  ),
                  const SizedBox(height: 24),
                ],

                // Portion & Frequency Guidance
                if (healthVerdict.portionGuidance != null ||
                    healthVerdict.frequencyGuidance != null) ...[
                  _buildPortionGuidance(context, healthVerdict),
                  const SizedBox(height: 24),
                ],

                // Nutrition Facts
                _buildNutritionFacts(context, product),
                const SizedBox(height: 24),

                // Ingredients
                if (product.ingredients.isNotEmpty) ...[
                  _buildIngredients(context, product),
                  const SizedBox(height: 24),
                ],

                // Allergens
                if (product.allergens != null &&
                    product.allergens!.isNotEmpty) ...[
                  _buildAllergens(context, product),
                  const SizedBox(height: 24),
                ],

                // Suggestions
                _buildSuggestions(context, healthVerdict),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductHeader(BuildContext context, product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.supportingSurface,
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textBody,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: AppTheme.textBody,
                      size: 40,
                    ),
            ),
            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textBody,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.supportingSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Barcode: ${product.barcode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryTheme,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthVerdict(BuildContext context, HealthVerdict verdict) {
    late Color verdictColor;
    late IconData verdictIcon;

    switch (verdict.type) {
      case VerdictType.good:
        verdictColor = AppTheme.successGreen;
        verdictIcon = Icons.check_circle;
        break;
      case VerdictType.warning:
        verdictColor = AppTheme.warningOrange;
        verdictIcon = Icons.warning;
        break;
      case VerdictType.bad:
        verdictColor = AppTheme.errorRed;
        verdictIcon = Icons.cancel;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(verdictIcon, color: verdictColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Health Verdict',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: verdictColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: verdictColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verdict.verdict,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: verdictColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verdict.explanation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionFacts(BuildContext context, product) {
    final nutrition = product.nutritionFacts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Nutrition Facts (per 100g)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutritionRow(context, 'Calories', nutrition.calories, 'kcal'),
            _buildNutritionRow(context, 'Protein', nutrition.protein, 'g'),
            _buildNutritionRow(
              context,
              'Carbohydrates',
              nutrition.carbohydrates,
              'g',
            ),
            _buildNutritionRow(context, 'Sugars', nutrition.sugars, 'g'),
            _buildNutritionRow(context, 'Fat', nutrition.fat, 'g'),
            _buildNutritionRow(
              context,
              'Saturated Fat',
              nutrition.saturatedFat,
              'g',
            ),
            _buildNutritionRow(context, 'Fiber', nutrition.fiber, 'g'),
            _buildNutritionRow(context, 'Salt', nutrition.salt, 'g'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
    BuildContext context,
    String label,
    double? value,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value != null ? '${value.toStringAsFixed(1)} $unit' : 'N/A',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: value != null ? AppTheme.textDark : AppTheme.textBody,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(BuildContext context, product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list, color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.ingredients.join(', '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergens(BuildContext context, product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning,
                    color: AppTheme.warningOrange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Allergens',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningOrange.withOpacity(0.3),
                ),
              ),
              child: Text(
                product.allergens!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedRecommendation(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) {
    Color recColor;
    IconData recIcon;

    switch (recommendation.type) {
      case RecommendationType.positive:
        recColor = AppTheme.successGreen;
        recIcon = Icons.check_circle;
        break;
      case RecommendationType.warning:
        recColor = AppTheme.warningOrange;
        recIcon = Icons.info;
        break;
      case RecommendationType.negative:
        recColor = AppTheme.errorRed;
        recIcon = Icons.cancel;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(recIcon, color: recColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Personalized Recommendation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: recColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: recColor.withOpacity(0.3)),
              ),
              child: Text(
                recommendation.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: recColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortionGuidance(
    BuildContext context,
    HealthVerdict verdict,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: AppTheme.primaryTheme,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Portion & Frequency Guidance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (verdict.frequencyGuidance != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppTheme.primaryTheme,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        verdict.frequencyGuidance!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (verdict.portionGuidance != null)
              Row(
                children: [
                  const Icon(
                    Icons.scale,
                    color: AppTheme.primaryTheme,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      verdict.portionGuidance!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, HealthVerdict verdict) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryTheme,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...verdict.suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTheme,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
