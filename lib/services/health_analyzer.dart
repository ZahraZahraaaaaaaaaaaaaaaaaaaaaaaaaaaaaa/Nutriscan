import '../models/product.dart';
import '../models/user_profile.dart';
import '../services/calorie_calculator.dart';

class PersonalizedRecommendation {
  final String message;
  final RecommendationType type;

  PersonalizedRecommendation({
    required this.message,
    required this.type,
  });
}

enum RecommendationType {
  positive,
  warning,
  negative,
}

class HealthVerdict {
  final String verdict;
  final String explanation;
  final List<String> suggestions;
  final VerdictType type;
  final PersonalizedRecommendation? personalizedRecommendation;
  final String? portionGuidance;
  final String? frequencyGuidance;

  HealthVerdict({
    required this.verdict,
    required this.explanation,
    required this.suggestions,
    required this.type,
    this.personalizedRecommendation,
    this.portionGuidance,
    this.frequencyGuidance,
  });
}

enum VerdictType { good, warning, bad }

class HealthAnalyzer {
  static HealthVerdict analyzeProduct(Product product, UserProfile? profile) {
    final nutrition = product.nutritionFacts;

    List<String> warnings = [];
    List<String> suggestions = [];
    VerdictType verdictType = VerdictType.good;
    PersonalizedRecommendation? personalizedRec;
    String? portionGuidance;
    String? frequencyGuidance;

    // If no profile exists, use default analysis
    if (profile == null || !profile.isComplete) {
      return _generateDefaultVerdict(nutrition, warnings, suggestions, verdictType);
    }

    // Analyze based on profile diseases
    if (profile.hasDiabetes) {
      if (nutrition.sugars != null && nutrition.sugars! > 10) {
        warnings.add('High sugar content');
        suggestions.add('Look for products with less than 10g sugar per 100g');
        verdictType = VerdictType.bad;
        personalizedRec = PersonalizedRecommendation(
          message: 'High sugar — not recommended for diabetes',
          type: RecommendationType.negative,
        );
      } else if (nutrition.sugars != null && nutrition.sugars! <= 5) {
        personalizedRec = PersonalizedRecommendation(
          message: 'Low sugar — suitable for diabetes management',
          type: RecommendationType.positive,
        );
      }
    }

    if (profile.hasHeartDisease || profile.hasHighCholesterol) {
      if (nutrition.saturatedFat != null && nutrition.saturatedFat! > 3) {
        warnings.add('High saturated fat');
        suggestions.add('Choose heart-healthy alternatives with less saturated fat');
        if (verdictType != VerdictType.bad) verdictType = VerdictType.warning;
        personalizedRec = PersonalizedRecommendation(
          message: 'High saturated fat — limit for heart health',
          type: RecommendationType.warning,
        );
      } else if (nutrition.saturatedFat != null &&
          nutrition.saturatedFat! <= 2) {
        if (personalizedRec == null) {
          personalizedRec = PersonalizedRecommendation(
            message: 'Suitable for heart health (low saturated fat)',
            type: RecommendationType.positive,
          );
        }
      }
    }

    if (profile.hasObesity || profile.goal == HealthGoal.loseWeight) {
      if (nutrition.calories != null) {
        final dailyCalories = CalorieCalculator.calculateRecommendedCalories(profile);
        if (dailyCalories != null) {
          final percentage = CalorieCalculator.getDailyCaloriePercentage(
            nutrition.calories!,
            profile,
          );
          if (percentage != null && percentage > 20) {
            warnings.add('High calorie content');
            suggestions.add('Consider portion size for weight loss goal');
            if (verdictType != VerdictType.bad) verdictType = VerdictType.warning;
            personalizedRec = PersonalizedRecommendation(
              message: 'High calories — limit portion for weight loss goal',
              type: RecommendationType.warning,
            );
            portionGuidance = 'This product provides ~${percentage.round()}% of your daily calorie intake';
          }
        }
      }
    }

    if (profile.goal == HealthGoal.gainWeight) {
      if (nutrition.calories != null && nutrition.calories! > 300) {
        if (personalizedRec == null) {
          personalizedRec = PersonalizedRecommendation(
            message: 'Good calorie content for weight gain goal',
            type: RecommendationType.positive,
          );
        }
      }
    }

    // General nutrition analysis
    if (nutrition.sugars != null && nutrition.sugars! > 25) {
      warnings.add('High sugar content');
      suggestions.add('Look for products with less sugar');
      if (verdictType != VerdictType.bad) verdictType = VerdictType.warning;
    }

    if (nutrition.fat != null && nutrition.fat! > 20) {
      warnings.add('High fat content');
      suggestions.add('Choose products with lower fat content');
      if (verdictType != VerdictType.bad) verdictType = VerdictType.warning;
    }

    if (nutrition.saturatedFat != null && nutrition.saturatedFat! > 5) {
      warnings.add('High saturated fat');
      suggestions.add('Limit saturated fat intake for better heart health');
      verdictType = VerdictType.bad;
    }

    if (nutrition.salt != null && nutrition.salt! > 1.5) {
      warnings.add('High salt content');
      suggestions.add('Reduce salt intake to maintain healthy blood pressure');
      if (verdictType != VerdictType.bad) verdictType = VerdictType.warning;
    }

    // Generate portion and frequency guidance
    if (nutrition.calories != null) {
      final dailyCalories = CalorieCalculator.calculateRecommendedCalories(profile);
      if (dailyCalories != null) {
        final percentage = CalorieCalculator.getDailyCaloriePercentage(
          nutrition.calories!,
          profile,
        );
        if (percentage != null) {
          if (percentage > 30) {
            portionGuidance = 'High calorie — consume in small portions';
            frequencyGuidance = 'Best consumed occasionally';
          } else if (percentage > 15) {
            portionGuidance = 'Moderate calorie content';
            frequencyGuidance = 'Okay for one serving';
          } else {
            portionGuidance = 'Low calorie content';
            frequencyGuidance = 'Suitable for regular consumption';
          }
        }
      }
    }

    // Generate verdict and explanation
    String verdict;
    String explanation;

    if (warnings.isEmpty) {
      verdict = 'Good for Health';
      explanation =
          'This product meets healthy nutrition guidelines for your profile.';
    } else if (verdictType == VerdictType.bad) {
      verdict = 'Not Recommended';
      explanation =
          'This product has concerning nutrition values: ${warnings.join(', ')}.';
    } else {
      verdict = 'Use with Caution';
      explanation =
          'This product has some nutrition concerns: ${warnings.join(', ')}.';
    }

    // Add general suggestions if none exist
    if (suggestions.isEmpty) {
      suggestions.add('Continue making healthy food choices!');
    }

    return HealthVerdict(
      verdict: verdict,
      explanation: explanation,
      suggestions: suggestions,
      type: verdictType,
      personalizedRecommendation: personalizedRec,
      portionGuidance: portionGuidance,
      frequencyGuidance: frequencyGuidance,
    );
  }

  static HealthVerdict _generateDefaultVerdict(
    NutritionFacts nutrition,
    List<String> warnings,
    List<String> suggestions,
    VerdictType verdictType,
  ) {
    // Default analysis without profile
    if (nutrition.sugars != null && nutrition.sugars! > 25) {
      warnings.add('High sugar content');
      suggestions.add('Look for products with less sugar');
      verdictType = VerdictType.warning;
    }

    if (nutrition.fat != null && nutrition.fat! > 20) {
      warnings.add('High fat content');
      suggestions.add('Choose products with lower fat content');
      verdictType = VerdictType.warning;
    }

    if (nutrition.saturatedFat != null && nutrition.saturatedFat! > 5) {
      warnings.add('High saturated fat');
      suggestions.add('Limit saturated fat intake');
      verdictType = VerdictType.bad;
    }

    if (nutrition.salt != null && nutrition.salt! > 1.5) {
      warnings.add('High salt content');
      suggestions.add('Reduce salt intake');
      verdictType = VerdictType.warning;
    }

    String verdict;
    String explanation;

    if (warnings.isEmpty) {
      verdict = 'Good for Health';
      explanation = 'This product meets general healthy nutrition guidelines.';
    } else if (verdictType == VerdictType.bad) {
      verdict = 'Not Recommended';
      explanation =
          'This product has concerning nutrition values: ${warnings.join(', ')}.';
    } else {
      verdict = 'Use with Caution';
      explanation =
          'This product has some nutrition concerns: ${warnings.join(', ')}.';
    }

    if (suggestions.isEmpty) {
      suggestions.add('Continue making healthy food choices!');
    }

    return HealthVerdict(
      verdict: verdict,
      explanation: explanation,
      suggestions: suggestions,
      type: verdictType,
    );
  }
}
