import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

/// Debug screen to test Firebase Realtime Database connection
class FirebaseDebugScreen extends ConsumerWidget {
  const FirebaseDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabVisibilityAsync = ref.watch(tabVisibilityProvider);
    final buttonVisibilityAsync = ref.watch(buttonVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade900, Colors.blue.shade900],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Tab Visibility Card
              tabVisibilityAsync.when(
                data: (visibility) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Firebase Connected ✓',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 20),
                          const Text(
                            'Tab Visibility Status:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildStatusRow(
                            'AI Hub',
                            visibility['aiHub'] ?? false,
                          ),
                          _buildStatusRow(
                            'Movies',
                            visibility['movies'] ?? false,
                          ),
                          _buildStatusRow('TV', visibility['tv'] ?? false),
                          _buildStatusRow(
                            'Watchlist',
                            visibility['watchlist'] ?? false,
                          ),
                          _buildStatusRow(
                            'Settings',
                            visibility['settings'] ?? false,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Card(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text(
                          'Connecting to Firebase...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 20),
                        const Text(
                          'Firebase Connection Error',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          error.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Button Visibility Card
              buttonVisibilityAsync.when(
                data: (buttonVis) {
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.amber,
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Button Visibility Status:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildStatusRow(
                            'Watch Trailer',
                            buttonVis['watchTrailer'] ?? false,
                          ),
                          _buildStatusRow(
                            'Watch Movie',
                            buttonVis['watchMovie'] ?? false,
                          ),
                          _buildStatusRow(
                            'Watch Series',
                            buttonVis['watchSeries'] ?? false,
                          ),
                          _buildStatusRow(
                            'Set Reminder',
                            buttonVis['setReminder'] ?? false,
                          ),
                          _buildStatusRow(
                            'Add to Watchlist',
                            buttonVis['addToWatchlist'] ?? false,
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 10),
                          const Text(
                            '💡 Change values in Firebase Console to see real-time updates!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Error loading button visibility',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isVisible
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVisible ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: isVisible ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isVisible ? 'Visible' : 'Hidden',
                  style: TextStyle(
                    color: isVisible ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
