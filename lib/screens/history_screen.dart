import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/providers/product_provider.dart';
import 'product_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _viewProduct(product) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Create a new ProductProvider instance with the cached product
    // This is a workaround since we can't directly set private fields
    await productProvider.fetchProductByBarcode(product.barcode);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Favorites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent Scans'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(context, historyProvider),
              _buildFavoritesTab(context, historyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    if (historyProvider.history.isEmpty) {
      return _buildEmptyState(
        context,
        'No Recent Scans',
        'Start scanning products to see them here',
        Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyProvider.history.length,
      itemBuilder: (context, index) {
        final product = historyProvider.history[index];
        return _buildProductCard(
          context,
          product,
          historyProvider,
          isHistory: true,
        );
      },
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    if (historyProvider.favorites.isEmpty) {
      return _buildEmptyState(
        context,
        'No Favorites',
        'Tap the heart icon on any product to add it to favorites',
        Icons.favorite_border,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyProvider.favorites.length,
      itemBuilder: (context, index) {
        final product = historyProvider.favorites[index];
        return _buildProductCard(
          context,
          product,
          historyProvider,
          isHistory: false,
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    product,
    HistoryProvider historyProvider, {
    required bool isHistory,
  }) {
    final isFavorite = historyProvider.isFavorite(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewProduct(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.supportingSurface,
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
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
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
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
                    const SizedBox(height: 4),
                    Text(
                      'Barcode: ${product.barcode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryTheme,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  if (isHistory)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppTheme.primaryTheme
                            : AppTheme.textBody,
                      ),
                      onPressed: () => historyProvider.toggleFavorite(product),
                    ),
                  const Icon(Icons.chevron_right, color: AppTheme.textBody),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppTheme.textBody),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.textBody),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textBody),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
