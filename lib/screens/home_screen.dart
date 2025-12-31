import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'scanner_screen.dart';
import 'manual_entry_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFE8F2FF),
              Color(0xFFF0F8FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer2<UserProfileProvider, HistoryProvider>(
            builder: (context, profileProvider, historyProvider, child) {
              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF8F9FF),
                              Color(0xFFE8F2FF),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedBuilder(
                                animation: _buttonAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _buttonAnimation.value,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'NutriScan',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
                                        ),
                                        Text(
                                          'Smart Food Scanner',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.textBody,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  _buildFloatingActionButton(
                                    context,
                                    Icons.person,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileScreen()),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildFloatingActionButton(
                                    context,
                                    Icons.history,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HistoryScreen()),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildFloatingActionButton(
                                    context,
                                    Icons.settings,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen()),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Hero Section
                  SliverToBoxAdapter(
                    child: _buildHeroSection(context, profileProvider),
                  ),

                  // Action Buttons Section
                  SliverToBoxAdapter(
                    child: _buildActionButtonsSection(context),
                  ),

                  // Quick Stats
                  SliverToBoxAdapter(
                    child: _buildQuickStats(context, historyProvider),
                  ),

                  // Recent Scans Button
                  SliverToBoxAdapter(
                    child: _buildRecentScansButton(context, historyProvider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    UserProfileProvider profileProvider,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0F5),
            Color(0xFFF0F8FF),
            Color(0xFFF5F0FF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTheme.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Welcome Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryTheme, AppTheme.primaryButton],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTheme.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: AppTheme.textWhite,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Welcome Text
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 8),

          if (profileProvider.hasProfile)
            Text(
              'Profile Complete',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryTheme,
                    fontWeight: FontWeight.w600,
                  ),
            )
          else
            Text(
              'Complete your profile for personalized recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warningOrange,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),

          Text(
            'Scan any food product barcode to get instant nutrition analysis and health recommendations tailored to your profile.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textBody,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              children: [
                // Scan Button
                Expanded(
                  child: _buildFloatingButton(
                    context,
                    'Scan Barcode',
                    Icons.qr_code_scanner,
                    AppTheme.primaryButton,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Manual Entry Button
                Expanded(
                  child: _buildFloatingButton(
                    context,
                    'Manual Entry',
                    Icons.keyboard,
                    AppTheme.secondaryButton,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualEntryScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Scanned',
              '${historyProvider.history.length}',
              Icons.scanner,
              Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              context,
              'Favorites',
              '${historyProvider.favorites.length}',
              Icons.favorite,
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitBullet(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryTheme.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryTheme,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textBody,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildScannerIllustration(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scanner Device
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.textWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scanner Screen
                Container(
                  width: 160,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.textDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: AppTheme.textWhite,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Scan Button
                Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryButton,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Scan Beam Animation
          Positioned(
            top: 20,
            child: AnimatedBuilder(
              animation: _buttonController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _buttonController.value * 100),
                  child: Container(
                    width: 160,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.textWhite.withOpacity(0.8),
                          AppTheme.textWhite.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              },
            ),
          ),

          // Food Item
          Positioned(
            bottom: 40,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.textWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.local_dining,
                  color: AppTheme.primaryTheme,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFloatingButton(
            context,
            'Scan Barcode',
            Icons.qr_code_scanner,
            AppTheme.primaryButton,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerScreen()),
            ),
          ),
          const SizedBox(width: 16),
          _buildFloatingButton(
            context,
            'Enter Barcode',
            Icons.keyboard,
            AppTheme.secondaryButton,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ManualEntryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppTheme.textWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTheme.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'fab_${icon.codePoint}', // Unique tag for each button
        onPressed: onPressed,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        mini: true,
        child: Icon(
          icon,
          color: AppTheme.primaryTheme,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRecentScansButton(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: _buildFloatingButton(
        context,
        'View Recent Scans (${historyProvider.history.length})',
        Icons.history,
        AppTheme.primaryTheme,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 15.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: _shadowAnimation.value,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: _shadowAnimation.value * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
