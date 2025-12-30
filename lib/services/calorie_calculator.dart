import '../models/user_profile.dart';

class CalorieCalculator {
  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  static double? calculateBMR(UserProfile profile) {
    if (profile.age == null ||
        profile.gender == null ||
        profile.height == null ||
        profile.weight == null) {
      return null;
    }

    // BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(years) + s
    // s = +5 for males, -161 for females, 0 for other (using average)
    // At this point gender is guaranteed to be non-null due to check above
    final gender = profile.gender!;
    double s = 0;
    switch (gender) {
      case Gender.male:
        s = 5;
        break;
      case Gender.female:
        s = -161;
        break;
      case Gender.other:
        s = -78; // Average between male and female
        break;
    }

    return 10 * profile.weight! +
        6.25 * profile.height! -
        5 * profile.age! +
        s;
  }

  /// Calculate Total Daily Energy Expenditure (TDEE) with activity factor
  /// Using sedentary activity level (1.2) as default
  static double? calculateTDEE(UserProfile profile, {double activityFactor = 1.2}) {
    final bmr = calculateBMR(profile);
    if (bmr == null) return null;
    return bmr * activityFactor;
  }

  /// Calculate recommended daily calorie intake based on goal
  static double? calculateRecommendedCalories(UserProfile profile) {
    final tdee = calculateTDEE(profile);
    if (tdee == null || profile.goal == null) return tdee;

    // At this point goal is guaranteed to be non-null due to check above
    final goal = profile.goal!;
    switch (goal) {
      case HealthGoal.maintainWeight:
        return tdee;
      case HealthGoal.loseWeight:
        // Subtract 500 kcal for ~0.5kg per week weight loss
        return (tdee - 500).clamp(1200, double.infinity);
      case HealthGoal.gainWeight:
        // Add 500 kcal for ~0.5kg per week weight gain
        return tdee + 500;
      case HealthGoal.eatHealthier:
        // Slight reduction for healthier eating
        return (tdee - 200).clamp(1200, double.infinity);
    }
  }

  /// Get meal split suggestions
  static Map<String, double> getMealSplit() {
    return {
      'Breakfast': 0.25,
      'Lunch': 0.35,
      'Dinner': 0.30,
      'Snacks': 0.10,
    };
  }

  /// Calculate percentage of daily calories in a product
  static double? getDailyCaloriePercentage(
    double productCalories,
    UserProfile profile,
  ) {
    final recommended = calculateRecommendedCalories(profile);
    if (recommended == null || recommended == 0) return null;
    return (productCalories / recommended * 100).clamp(0, 100);
  }
}

