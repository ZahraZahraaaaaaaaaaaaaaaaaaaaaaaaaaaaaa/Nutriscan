import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/product_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/widgets/product_result_dialog.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode() async {
    if (!_formKey.currentState!.validate()) return;

    final barcode = _barcodeController.text.trim();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryTheme),
              ),
              const SizedBox(height: 16),
              Text(
                'Analyzing product...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await productProvider.fetchProductByBarcode(barcode);

      if (productProvider.currentProduct != null) {
        // Add to history
        await historyProvider.addToHistory(productProvider.currentProduct!);

        // Show result dialog
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          _showResultDialog(
              productProvider.currentProduct!, profileProvider.profile);
        }
      } else {
        // Show error
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          _showErrorDialog(productProvider.error ?? 'Unknown error occurred');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Failed to process barcode: $e');
      }
    }
  }

  void _showResultDialog(product, profile) {
    showDialog(
      context: context,
      builder: (context) => ProductResultDialog(
        product: product,
        profile: profile,
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.keyboard,
                        size: 64,
                        color: AppTheme.primaryTheme,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Manual Barcode Entry',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the barcode number manually to analyze the product',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Barcode Input
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode Number',
                  hintText: 'Enter 8-13 digit barcode',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a barcode number';
                  }
                  if (value.length < 8) {
                    return 'Barcode must be at least 8 digits';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _processBarcode(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _processBarcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryButton,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Analyze Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Card(
                color: AppTheme.supportingSurface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryTheme,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Most food products have 8-13 digit barcodes\n'
                        '• Look for the barcode on the product packaging\n'
                        '• Common formats: EAN-8, EAN-13, UPC-A, UPC-E',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
