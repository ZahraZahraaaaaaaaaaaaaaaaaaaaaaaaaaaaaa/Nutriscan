import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/providers/auth_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/models/user_profile.dart';
import 'package:smart_food_scanner/services/calorie_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late int? _age;
  late Gender? _gender;
  late double? _height;
  late double? _weight;
  late List<Disease> _diseases;
  late HealthGoal? _goal;

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<UserProfileProvider>(context, listen: false).profile;
    _age = profile.age;
    _gender = profile.gender;
    _height = profile.height;
    _weight = profile.weight;
    _diseases = List.from(profile.diseases);
    _goal = profile.goal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildAccountSection(context),
                  const SizedBox(height: 24),

                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // Required Fields Section
                  _buildSectionHeader(context, 'Basic Information'),
                  const SizedBox(height: 12),

                  // Age
                  _buildNumberField(
                    context,
                    'Age',
                    'Enter your age',
                    _age?.toString() ?? '',
                    (value) => _age = int.tryParse(value),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  _buildGenderSelector(context),
                  const SizedBox(height: 16),

                  // Height
                  _buildNumberField(
                    context,
                    'Height (cm)',
                    'Enter your height in centimeters',
                    _height?.toString() ?? '',
                    (value) => _height = double.tryParse(value),
                  ),
                  const SizedBox(height: 16),

                  // Weight
                  _buildNumberField(
                    context,
                    'Weight (kg)',
                    'Enter your weight in kilograms',
                    _weight?.toString() ?? '',
                    (value) => _weight = double.tryParse(value),
                  ),
                  const SizedBox(height: 24),

                  // Optional Fields Section
                  _buildSectionHeader(context, 'Health Conditions (Optional)'),
                  const SizedBox(height: 12),
                  _buildDiseaseCheckboxes(context),
                  const SizedBox(height: 24),

                  // Goal Section
                  _buildSectionHeader(context, 'Health Goal (Optional)'),
                  const SizedBox(height: 12),
                  _buildGoalSelector(context),
                  const SizedBox(height: 24),

                  // Daily Calorie Recommendation
                  if (_age != null &&
                      _gender != null &&
                      _height != null &&
                      _weight != null)
                    _buildCalorieRecommendation(context),
                  const SizedBox(height: 24),

                  // Health Focus Summary
                  if (profileProvider.hasProfile) _buildHealthFocus(context),
                  const SizedBox(height: 24),

                  // Disclaimer
                  _buildDisclaimer(context),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isGuest = authProvider.isGuest;
        final isAuthenticated = authProvider.isAuthenticated;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle,
                        color: AppTheme.primaryTheme, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isGuest) ...[
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppTheme.supportingSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.textBody,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest User',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You\'re using NutriScan as a guest',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _signInToSync(context),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Sign in to sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTheme,
                        foregroundColor: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ] else if (isAuthenticated) ...[
                  Row(
                    children: [
                      authProvider.photoURL != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: authProvider.photoURL!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppTheme.supportingSurface,
                                  child: const Icon(Icons.person),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.supportingSurface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person),
                                ),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: AppTheme.supportingSurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.textBody,
                                size: 30,
                              ),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.displayName ?? 'User',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (authProvider.email != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                authProvider.email!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _signOut(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signInToSync(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final profileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await authProvider.signInWithGoogle();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Merge local data to cloud
        await profileProvider.syncToCloud();
        await historyProvider.syncToCloud();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully! Your data is now synced.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
            'Are you sure you want to sign out? Your data will remain stored locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Signed out successfully. You can continue as a guest.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryTheme, AppTheme.primaryButton],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Health Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalize your nutrition guidance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTheme,
          ),
    );
  }

  Widget _buildNumberField(
    BuildContext context,
    String label,
    String hint,
    String initialValue,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderChip(
                context,
                'Male',
                Gender.male,
                Icons.male,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderChip(
                context,
                'Female',
                Gender.female,
                Icons.female,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderChip(
                context,
                'Other',
                Gender.other,
                Icons.person,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(
    BuildContext context,
    String label,
    Gender gender,
    IconData icon,
  ) {
    final isSelected = _gender == gender;
    return InkWell(
      onTap: () => setState(() => _gender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryTheme.withOpacity(0.1)
              : AppTheme.supportingSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTheme : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryTheme : AppTheme.textBody,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isSelected ? AppTheme.primaryTheme : AppTheme.textBody,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCheckboxes(BuildContext context) {
    final diseases = [
      Disease.diabetes,
      Disease.heartDisease,
      Disease.highCholesterol,
      Disease.obesity,
      Disease.pcos,
    ];

    return Column(
      children: diseases.map((disease) {
        final isSelected = _diseases.contains(disease);
        return CheckboxListTile(
          title: Text(_getDiseaseLabel(disease)),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                if (!_diseases.contains(disease)) {
                  _diseases.add(disease);
                }
              } else {
                _diseases.remove(disease);
              }
            });
          },
          activeColor: AppTheme.primaryTheme,
        );
      }).toList(),
    );
  }

  String _getDiseaseLabel(Disease disease) {
    switch (disease) {
      case Disease.diabetes:
        return 'Diabetes';
      case Disease.heartDisease:
        return 'Heart disease / High blood pressure';
      case Disease.highCholesterol:
        return 'High cholesterol';
      case Disease.obesity:
        return 'Obesity';
      case Disease.pcos:
        return 'PCOS';
      case Disease.none:
        return 'None';
    }
  }

  Widget _buildGoalSelector(BuildContext context) {
    final goals = [
      HealthGoal.maintainWeight,
      HealthGoal.loseWeight,
      HealthGoal.gainWeight,
      HealthGoal.eatHealthier,
    ];

    return Column(
      children: goals.map((goal) {
        return RadioListTile<HealthGoal>(
          title: Text(_getGoalLabel(goal)),
          value: goal,
          groupValue: _goal,
          onChanged: (value) => setState(() => _goal = value),
          activeColor: AppTheme.primaryTheme,
        );
      }).toList(),
    );
  }

  String _getGoalLabel(HealthGoal goal) {
    switch (goal) {
      case HealthGoal.maintainWeight:
        return 'Maintain weight';
      case HealthGoal.loseWeight:
        return 'Lose weight';
      case HealthGoal.gainWeight:
        return 'Gain weight';
      case HealthGoal.eatHealthier:
        return 'Eat healthier';
    }
  }

  Widget _buildCalorieRecommendation(BuildContext context) {
    final profile = UserProfile(
      age: _age,
      gender: _gender,
      height: _height,
      weight: _weight,
      diseases: _diseases,
      goal: _goal,
    );

    final recommendedCalories =
        CalorieCalculator.calculateRecommendedCalories(profile);
    final mealSplit = CalorieCalculator.getMealSplit();

    if (recommendedCalories == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Daily Calorie Guidance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryTheme.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${recommendedCalories.round()} kcal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTheme,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your recommended daily intake',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Suggested meal split:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            ...mealSplit.entries.map((entry) {
              final calories = (recommendedCalories * entry.value).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '$calories kcal (~${(entry.value * 100).round()}%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryTheme,
                          ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'This is guidance only. No strict enforcement.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textBody,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFocus(BuildContext context) {
    final profile = UserProfile(
      age: _age,
      gender: _gender,
      height: _height,
      weight: _weight,
      diseases: _diseases,
      goal: _goal,
    );

    final focusMore = <String>[];
    final limit = <String>[];
    final recommendedFoods = <String>[];

    // Based on diseases
    if (profile.hasDiabetes) {
      limit.add('Added sugar');
      recommendedFoods.add('Whole grains');
      recommendedFoods.add('High-fiber foods');
    }
    if (profile.hasHeartDisease || profile.hasHighCholesterol) {
      limit.add('Saturated fat');
      limit.add('Sodium');
      recommendedFoods.add('Lean protein');
      recommendedFoods.add('Vegetables');
    }
    if (profile.hasObesity || profile.goal == HealthGoal.loseWeight) {
      limit.add('High-calorie foods');
      recommendedFoods.add('Low-calorie vegetables');
    }
    if (profile.hasPCOS) {
      limit.add('Refined carbohydrates');
      recommendedFoods.add('Complex carbohydrates');
    }

    // Default recommendations
    if (focusMore.isEmpty) {
      focusMore.add('Fiber');
      focusMore.add('Protein');
    }
    if (limit.isEmpty) {
      limit.add('Added sugar');
      limit.add('Saturated fat');
    }
    if (recommendedFoods.isEmpty) {
      recommendedFoods.add('Vegetables');
      recommendedFoods.add('Whole grains');
      recommendedFoods.add('Lean protein');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Health Focus',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFocusCard(
              context,
              'Focus more on:',
              focusMore.join(', '),
              AppTheme.successGreen,
            ),
            const SizedBox(height: 12),
            _buildFocusCard(
              context,
              'Limit:',
              limit.join(', '),
              AppTheme.warningOrange,
            ),
            const SizedBox(height: 12),
            _buildFocusCard(
              context,
              'Recommended food types:',
              recommendedFoods.join(', '),
              AppTheme.primaryTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.supportingSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.textBody,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'NutriScan provides general nutrition guidance, not medical advice.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textBody,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        age: _age,
        gender: _gender,
        height: _height,
        weight: _weight,
        diseases: _diseases,
        goal: _goal,
      );

      Provider.of<UserProfileProvider>(context, listen: false)
          .saveProfile(profile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      Navigator.pop(context);
    }
  }
}
