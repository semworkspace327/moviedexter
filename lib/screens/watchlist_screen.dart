import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_providers.dart';
import '../providers/tmdb_providers.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';
import 'package:intl/intl.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();

    // Add listener to reload reminders when switching to reminders tab
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _loadReminders();
      }
    });
  }

  void _loadReminders() {
    setState(() {
      _reminders = _reminderService.getAllReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              child: const Text(
                'My Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.bookmark_rounded), text: 'Watchlist'),
                  Tab(
                    icon: Icon(Icons.notifications_active_rounded),
                    text: 'Reminders',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildWatchlistTab(), _buildRemindersTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistTab() {
    final keys = ref.watch(watchlistProvider).toList()..sort();

    if (keys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Your watchlist is empty',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ).copyWith(bottom: 100),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final k = keys[index];
        final parts = k.split(':');
        final type = parts[0];
        final id = int.tryParse(parts[1]) ?? 0;
        final details = ref.watch(detailsProvider((id: id, type: type)));

        return details.when(
          data: (d) => _buildWatchlistItem(context, d, type, id, k),
          loading: () => _buildLoadingItem(),
          error: (e, _) => _buildErrorItem(k),
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    // Use the state variable instead of calling getAllReminders directly
    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders set',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ).copyWith(bottom: 100),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderItem(reminder);
      },
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Extract type and id from watchlistItemId (format: "type:id")
    final parts = reminder.watchlistItemId.split(':');
    final type = parts.isNotEmpty ? parts[0] : 'movie';
    final id = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to details screen when tapped
          context.push('/details/$type/$id');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Poster
                if (reminder.moviePosterUrl != null &&
                    reminder.moviePosterUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: reminder.moviePosterUrl!,
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.movie,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with type badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.movieTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Type badge (Movie or Series)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: type == 'tv'
                                  ? Colors.purple.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: type == 'tv'
                                    ? Colors.purple.withOpacity(0.5)
                                    : Colors.blue.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              type == 'tv' ? 'SERIES' : 'MOVIE',
                              style: TextStyle(
                                color: type == 'tv'
                                    ? Colors.purpleAccent
                                    : Colors.blueAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(reminder.scheduledDateTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Time badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(reminder.scheduledDateTime),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await _reminderService.deleteReminder(reminder.id);
                    _loadReminders(); // Reload the reminders list
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistItem(
    BuildContext context,
    Map<String, dynamic> details,
    String type,
    int id,
    String key,
  ) {
    final title = (details['title'] ?? details['name'] ?? 'Unknown').toString();
    final posterPath = (details['poster_path'] ?? '').toString();
    final posterUrl = posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : '';
    final rating = (details['vote_average'] ?? 0.0) as num;
    final releaseDate =
        (details['release_date'] ?? details['first_air_date'] ?? '').toString();
    final year = releaseDate.isNotEmpty && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => context.push('/details/$type/$id'),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: posterUrl,
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 110,
                          height: 160,
                          color: Colors.white.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 110,
                          height: 160,
                          color: Colors.white.withOpacity(0.1),
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        width: 110,
                        height: 160,
                        color: Colors.white.withOpacity(0.1),
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white38,
                          size: 40,
                        ),
                      ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: type == 'movie'
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: type == 'movie'
                                        ? Colors.blue.withOpacity(0.5)
                                        : Colors.purple.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  type == 'movie' ? 'Movie' : 'Series',
                                  style: TextStyle(
                                    color: type == 'movie'
                                        ? Colors.blue.shade200
                                        : Colors.purple.shade200,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (year.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  year,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.black,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Remove button
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_remove,
                              color: Colors.white70,
                              size: 22,
                            ),
                            onPressed: () => ref
                                .read(watchlistProvider.notifier)
                                .toggle(key),
                            tooltip: 'Remove from watchlist',
                          ),
                        ],
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

  Widget _buildLoadingItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }

  Widget _buildErrorItem(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white.withOpacity(0.5),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              Text(
                key,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
