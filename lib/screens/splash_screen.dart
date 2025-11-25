import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/notification_service.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _dotsController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _loadingProgress;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _navigationTimer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();

    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initializeAnimations() {
    // Loading animation controller - 5 seconds
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Dots animation controller
    _dotsController =
        AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        )..addListener(() {
          setState(() {
            _dotCount = (_dotsController.value * 3).floor();
          });
        });

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading progress animation
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Scale animation with bounce
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startSplashSequence() async {
    // Start title animations
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    _scaleController.forward();

    // Start loading animation
    await Future.delayed(const Duration(milliseconds: 800));
    _loadingController.forward();

    // Start dots animation (repeat)
    _dotsController.repeat();

    // Request permissions early (notifications & tracking)
    await _requestPermissions();

    // Check Firebase connection
    final isConnected = await _checkFirebaseConnection();

    if (!isConnected && mounted) {
      _showConnectionError();
      return;
    }

    // Navigate after loading completes
    _navigationTimer = Timer(const Duration(milliseconds: 6000), () {
      _navigateToHome();
    });
  }

  Future<void> _requestPermissions() async {
    try {
      // Request ATT permission for iOS (for AdMob personalized ads)
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }

      // Request notification permissions
      final notificationService = NotificationService();
      await notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  Future<bool> _checkFirebaseConnection() async {
    try {
      final database = FirebaseDatabase.instance;
      // Try to read from a simple path with timeout
      final snapshot = await database
          .ref('tabVisibility')
          .get()
          .timeout(const Duration(seconds: 5));
      return snapshot.exists;
    } catch (e) {
      debugPrint('Firebase connection error: $e');
      return false;
    }
  }

  void _showConnectionError() {
    // Stop animations
    _loadingController.stop();
    _dotsController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Verify the connection',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset and retry connection
              _loadingController.reset();
              _dotsController.reset();
              _startSplashSequence();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Close the app properly on both iOS and Android
              if (Platform.isIOS) {
                exit(0);
              } else {
                SystemNavigator.pop();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Exit',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      // Restore status bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      context.go('/');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _loadingController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final iconSize = isTablet ? 120.0 : 80.0;
    final iconPadding = isTablet ? 36.0 : 24.0;
    final titleFontSize = isTablet ? 56.0 : 42.0;
    final subtitleFontSize = isTablet ? 22.0 : 16.0;
    final loadingBarWidth = isTablet ? 450.0 : 300.0;
    final loadingTextSize = isTablet ? 20.0 : 15.0;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A0E27),
                Color(0xFF1A1F3A),
                Color(0xFF2D1B4E),
                Color(0xFF1A1F3A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated glow effect
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8 * _scaleAnimation.value,
                          colors: [
                            const Color(
                              0xFF667eea,
                            ).withOpacity(0.1 * _fadeAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              Center(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo icon at top
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _fadeController,
                          _scaleController,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.movie_filter_rounded,
                            size: iconSize,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 60 : 40),

                      // Animated Title
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _fadeController,
                          _scaleController,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFE0E0E0),
                              Color(0xFFFFFFFF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Movie Dexter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: const [
                                Shadow(
                                  color: Color(0x60000000),
                                  offset: Offset(0, 6),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: Color(0x30667eea),
                                  offset: Offset(0, 0),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 30 : 20),

                      // Subtitle
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          );
                        },
                        child: Text(
                          'Your Ultimate Movie Guide',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Loading section
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _loadingProgress.value > 0.05 ? 1.0 : 0.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 100 : 60,
                              ),
                              child: Column(
                                children: [
                                  _buildLoadingBar(loadingBarWidth),
                                  SizedBox(height: isTablet ? 30 : 20),
                                  Text(
                                    'Loading${'.' * (_dotCount + 1)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: loadingTextSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const Spacer(flex: 1),
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

  Widget _buildLoadingBar(double width) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress bar with enhanced gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: width * _loadingProgress.value,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFFf093fb),
                  Color(0xFFfbc2eb),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFf093fb).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Shimmer effect
          if (_loadingProgress.value > 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: (width * _loadingProgress.value) - 40,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
