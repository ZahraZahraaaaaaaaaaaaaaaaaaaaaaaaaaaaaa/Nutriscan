import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<UserProfileProvider, HistoryProvider>(
        builder: (context, profileProvider, historyProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Health Profile Section
              _buildSectionHeader(context, 'Health Profile'),
              _buildProfileCard(context, profileProvider),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader(context, 'Data Management'),
              _buildDataManagementCard(context, historyProvider),
              const SizedBox(height: 24),

              // App Info Section
              _buildSectionHeader(context, 'App Information'),
              _buildAppInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTheme,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    UserProfileProvider profileProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Health Profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.supportingSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileProvider.hasProfile
                        ? 'Profile Complete'
                        : 'Profile Incomplete',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileProvider.hasProfile
                        ? 'Your health profile is set up and personalized recommendations are active.'
                        : 'Complete your health profile to get personalized nutrition recommendations.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: Text(profileProvider.hasProfile
                    ? 'Edit Profile'
                    : 'Set Up Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTheme,
                  foregroundColor: AppTheme.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataRow(
              context,
              'Recent Scans',
              '${historyProvider.history.length} items',
              Icons.history,
              () => _showClearDialog(
                context,
                'Clear History',
                'Are you sure you want to clear all recent scans?',
                () => historyProvider.clearHistory(),
              ),
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              context,
              'Favorites',
              '${historyProvider.favorites.length} items',
              Icons.favorite,
              () => _showClearDialog(
                context,
                'Clear Favorites',
                'Are you sure you want to clear all favorites?',
                () => historyProvider.clearFavorites(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textBody, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textBody),
                  ),
                ],
              ),
            ),
            const Icon(Icons.delete_outline,
                color: AppTheme.errorRed, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.primaryTheme, size: 24),
                const SizedBox(width: 8),
                Text(
                  'App Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Version', '1.0.0'),
            _buildInfoRow(context, 'Data Source', 'Open Food Facts'),
            _buildInfoRow(context, 'Privacy', 'Your data stays on your device'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textBody),
          ),
        ],
      ),
    );
  }


  void _showClearDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child:
                const Text('Clear', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}
