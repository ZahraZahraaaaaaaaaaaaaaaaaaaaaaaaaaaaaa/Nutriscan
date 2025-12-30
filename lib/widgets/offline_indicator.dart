import 'package:flutter/material.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/services/offline_cache_service.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _hasOfflineData = false;
  int? _cacheAgeHours;

  @override
  void initState() {
    super.initState();
    _checkOfflineData();
  }

  Future<void> _checkOfflineData() async {
    final hasData = await OfflineCacheService.hasValidCache();
    final ageHours = await OfflineCacheService.getCacheAgeInHours();

    if (mounted) {
      setState(() {
        _hasOfflineData = hasData;
        _cacheAgeHours = ageHours;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasOfflineData) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: AppTheme.warningOrange, size: 16),
          const SizedBox(width: 8),
          Text(
            'Offline data available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningOrange,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (_cacheAgeHours != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${_cacheAgeHours}h old)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningOrange.withOpacity(0.7),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
