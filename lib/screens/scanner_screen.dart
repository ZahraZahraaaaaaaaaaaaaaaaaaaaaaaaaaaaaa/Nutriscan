import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/product_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/widgets/product_result_dialog.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? barcode = barcodes.first.rawValue;
      if (barcode != null) {
        _isScanning = false;
        _processBarcode(barcode);
      }
    }
  }

  Future<void> _processBarcode(String barcode) async {
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
    ).then((_) {
      // Resume scanning after dialog is closed
      setState(() {
        _isScanning = true;
      });
    });
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
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Scanning Overlay
          _buildScanningOverlay(),

          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: AppTheme.primaryTheme,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Position the barcode within the frame',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Make sure the barcode is clearly visible and well-lit',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppTheme.primaryTheme,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutWidth =
        this.cutOutWidth < width ? this.cutOutWidth : width - borderOffset;
    final cutOutHeight =
        this.cutOutHeight < height ? this.cutOutHeight : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutWidth / 2 + borderOffset,
      rect.top + height / 2 - cutOutHeight / 2 + borderOffset,
      cutOutWidth - borderOffset * 2,
      cutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw border
    final path = Path()
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.left + borderRadius,
        cutOutRect.top - borderOffset,
      )
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset);

    canvas.drawPath(path, borderPaint);

    // Top right
    final path2 = Path()
      ..moveTo(cutOutRect.right + borderOffset, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.right - borderRadius,
        cutOutRect.top - borderOffset,
      )
      ..lineTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset);

    canvas.drawPath(path2, borderPaint);

    // Bottom left
    final path3 = Path()
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.bottom - borderLength)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.left + borderRadius,
        cutOutRect.bottom + borderOffset,
      )
      ..lineTo(
        cutOutRect.left + borderLength,
        cutOutRect.bottom + borderOffset,
      );

    canvas.drawPath(path3, borderPaint);

    // Bottom right
    final path4 = Path()
      ..moveTo(
        cutOutRect.right + borderOffset,
        cutOutRect.bottom - borderLength,
      )
      ..lineTo(
        cutOutRect.right + borderOffset,
        cutOutRect.bottom - borderRadius,
      )
      ..quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.right - borderRadius,
        cutOutRect.bottom + borderOffset,
      )
      ..lineTo(
        cutOutRect.right - borderLength,
        cutOutRect.bottom + borderOffset,
      );

    canvas.drawPath(path4, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
