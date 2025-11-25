import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/ai_hub_screen.dart';
import '../screens/movies_screen.dart';
import '../screens/tv_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/settings_screen.dart';
import '../services/ad_service.dart';
import '../screens/details_screen.dart';
import '../providers/app_providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash screen route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _GlassBottomNavScaffold(shell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'aihub',
                builder: (c, s) => const AIHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                name: 'movies',
                builder: (c, s) => const MoviesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tv',
                name: 'tv',
                builder: (c, s) => const TVScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/watchlist',
                name: 'watchlist',
                builder: (c, s) => const WatchlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (c, s) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/details/:type/:id',
        name: 'details',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final type = state.pathParameters['type'] ?? 'movie';
          return DetailsScreen(id: id, type: type);
        },
      ),
    ],
  );
});

class _GlassBottomNavScaffold extends ConsumerStatefulWidget {
  const _GlassBottomNavScaffold({required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<_GlassBottomNavScaffold> createState() =>
      _GlassBottomNavScaffoldState();
}

class _GlassBottomNavScaffoldState
    extends ConsumerState<_GlassBottomNavScaffold> {
  final AdService _adService = AdService();
  int _lastTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _GlassNavBar(
        currentIndex: widget.shell.currentIndex,
        onTap: (i) {
          if (i != _lastTabIndex) {
            // Show interstitial ad when switching tabs
            _adService.showInterstitialAd(
              onAdClosed: () {
                widget.shell.goBranch(
                  i,
                  initialLocation: i == widget.shell.currentIndex,
                );
                setState(() {
                  _lastTabIndex = i;
                });
              },
            );
          } else {
            widget.shell.goBranch(
              i,
              initialLocation: i == widget.shell.currentIndex,
            );
          }
        },
      ),
    );
  }
}

class _GlassNavBar extends ConsumerWidget {
  const _GlassNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the tab visibility from Firebase
    final tabVisibilityAsync = ref.watch(tabVisibilityProvider);

    // Define all tabs with their info
    final allTabs = [
      {'icon': Icons.auto_awesome, 'label': 'AI Hub', 'key': 'aiHub'},
      {'icon': Icons.movie, 'label': 'Discover', 'key': 'movies'},
      {'icon': Icons.tv, 'label': 'Series', 'key': 'tv'},
      {'icon': Icons.bookmark, 'label': 'Watchlist', 'key': 'watchlist'},
      {'icon': Icons.settings, 'label': 'Settings', 'key': 'settings'},
    ];

    return tabVisibilityAsync.when(
      data: (visibility) {
        // Filter visible tabs based on Firebase settings
        final visibleTabs = <Map<String, dynamic>>[];
        final indexMapping =
            <int, int>{}; // Maps visible index to original index

        for (int i = 0; i < allTabs.length; i++) {
          final tabKey = allTabs[i]['key'] as String;
          if (visibility[tabKey] == true) {
            indexMapping[visibleTabs.length] = i;
            visibleTabs.add(allTabs[i]);
          }
        }

        // If no tabs are visible, show settings by default
        if (visibleTabs.isEmpty) {
          visibleTabs.add(allTabs[4]); // Settings
          indexMapping[0] = 4;
        }

        // Find the current tab in visible tabs
        int visibleCurrentIndex = 0;
        for (int i = 0; i < visibleTabs.length; i++) {
          if (indexMapping[i] == currentIndex) {
            visibleCurrentIndex = i;
            break;
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: visibleTabs.asMap().entries.map((entry) {
                    final visibleIndex = entry.key;
                    final tab = entry.value;
                    final originalIndex = indexMapping[visibleIndex]!;

                    return _NavItem(
                      icon: tab['icon'] as IconData,
                      label: tab['label'] as String,
                      isSelected: visibleCurrentIndex == visibleIndex,
                      onTap: () => onTap(originalIndex),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildDefaultNavBar(),
      error: (_, __) => _buildDefaultNavBar(),
    );
  }

  Widget _buildDefaultNavBar() {
    // Show all tabs while loading or on error
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  icon: Icons.auto_awesome,
                  label: 'AI Hub',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.movie,
                  label: 'Discover',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.tv,
                  label: 'Series',
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.bookmark,
                  label: 'Watchlist',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSelected ? 28 : 24,
                color: isSelected
                    ? const Color(0xFFFFD233)
                    : Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFFD233)
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
