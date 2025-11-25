import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'services/app_initialization_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AdMob
  await AdService.initialize();

  // Load initial ads
  final adService = AdService();
  adService.loadInterstitialAd();
  adService.loadRewardedAd();
  adService.loadAppOpenAd(); // Load app open ad

  // Initialize app services (Hive, notifications, reminders)
  final appInit = AppInitializationService();
  final initialized = await appInit.initialize();

  if (!initialized) {
    debugPrint(
      'Failed to initialize app services - some features may not work',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AdService _adService = AdService();
  late AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    // Show app open ad AFTER splash screen completes
    // Splash takes ~6 seconds, so wait 7 seconds to show ad
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        _adService.showAppOpenAd();
      }
    });

    // Listen to app lifecycle changes to show app open ad when returning
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          // Show app open ad when app comes back from background
          _adService.showAppOpenAd();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(goRouterProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Movie Dexter',
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
    );
  }
}
