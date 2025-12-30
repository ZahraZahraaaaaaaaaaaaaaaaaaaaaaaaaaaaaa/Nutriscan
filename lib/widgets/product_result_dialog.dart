import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/models/product.dart';
import 'package:smart_food_scanner/services/health_analyzer.dart';
import 'package:smart_food_scanner/models/user_profile.dart';

class ProductResultDialog extends StatelessWidget {
  final Product product;
  final UserProfile? profile;

  const ProductResultDialog({
    super.key,
    required this.product,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final healthVerdict = HealthAnalyzer.analyzeProduct(product, profile);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with product image and name
            _buildHeader(context),

            // Health verdict
            _buildHealthVerdict(context, healthVerdict),

            // Personalized Recommendation
            if (healthVerdict.personalizedRecommendation != null)
              _buildPersonalizedRecommendation(
                context,
                healthVerdict.personalizedRecommendation!,
              ),

            // Quick nutrition facts
            _buildQuickNutrition(context),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.supportingSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.backgroundColor,
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported,
                        color: AppTheme.textBody,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    color: AppTheme.textBody,
                    size: 24,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textBody,
                      ),
                ),
              ],
            ),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verdictColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: verdictColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(verdictIcon, color: verdictColor, size: 24),
              const SizedBox(width: 8),
              Text(
                verdict.verdict,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: verdictColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            verdict.explanation,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNutrition(BuildContext context) {
    final nutrition = product.nutritionFacts;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.supportingSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Nutrition (per 100g)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                  context, 'Calories', nutrition.calories, 'kcal'),
              _buildNutritionItem(context, 'Sugar', nutrition.sugars, 'g'),
              _buildNutritionItem(context, 'Fat', nutrition.fat, 'g'),
              _buildNutritionItem(context, 'Salt', nutrition.salt, 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
      BuildContext context, String label, double? value, String unit) {
    return Column(
      children: [
        Text(
          value != null ? value.toStringAsFixed(0) : 'N/A',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
        ),
        Text(
          '$label $unit',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textBody,
              ),
        ),
      ],
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: recColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(recIcon, color: recColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: recColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textBody,
                side: const BorderSide(color: AppTheme.textBody),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to full details screen
                Navigator.pushNamed(context, '/product-details');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTheme,
                foregroundColor: AppTheme.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}
