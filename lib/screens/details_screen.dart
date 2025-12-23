import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../providers/tmdb_providers.dart';
import '../providers/app_providers.dart';
import '../models/video.dart';
import '../screens/schedule_screen.dart';
import '../screens/seasons_screen.dart';
import '../screens/watch_screen_v2.dart';
import '../services/reminder_service.dart';
import '../services/ad_service.dart';

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key, required this.id, required this.type});
  final int id;
  final String type; // 'movie' or 'tv'

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(detailsProvider((id: id, type: type)));
    final videos = ref.watch(detailsVideosProvider((id: id, type: type)));
    final credits = ref.watch(creditsProvider((id: id, type: type)));
    final watchlist = ref.watch(watchlistProvider);
    final buttonVisibilityAsync = ref.watch(buttonVisibilityProvider);
    final key = '$type:$id';
    final inWatchlist = watchlist.contains(key);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (d) {
          final posterPath = (d['poster_path'] as String?);
          final backdropPath = (d['backdrop_path'] as String?);
          final title = (d['title'] ?? d['name'] ?? '') as String;
          final rating = (d['vote_average'] as num?)?.toDouble() ?? 0;
          final release =
              (d['release_date'] ?? d['first_air_date'] ?? '') as String;
          final overview = (d['overview'] ?? '') as String;
          final genres =
              (d['genres'] as List?)
                  ?.map((e) => e['name'] as String)
                  .toList() ??
              const <String>[];
          final posterUrl = posterPath != null
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : '';
          final bgUrl = (backdropPath != null
              ? 'https://image.tmdb.org/t/p/w780$backdropPath'
              : posterUrl);

          return Stack(
            fit: StackFit.expand,
            children: [
              if (bgUrl.isNotEmpty)
                CachedNetworkImage(imageUrl: bgUrl, fit: BoxFit.cover),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 140, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (posterUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: posterUrl,
                              width: 140,
                              height: 210,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${rating.toStringAsFixed(1)}/10',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    release,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: genres
                                    .map(
                                      (g) => Chip(
                                        label: Text(g),
                                        backgroundColor: Colors.white12,
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overview,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons - Controlled by Firebase
                    buttonVisibilityAsync.when(
                      data: (btnVis) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Watch Trailer button
                          if (btnVis['watchTrailer'] == true) ...[
                            ElevatedButton.icon(
                              onPressed: videos.maybeWhen(
                                data: (v) {
                                  Video? trailer;
                                  try {
                                    trailer = v.firstWhere(
                                      (x) =>
                                          (x.type.toLowerCase() == 'trailer' ||
                                              x.name.toLowerCase().contains(
                                                'trailer',
                                              )) &&
                                          x.isYouTube,
                                    );
                                  } catch (_) {
                                    try {
                                      trailer = v.firstWhere(
                                        (x) => x.isYouTube,
                                      );
                                    } catch (_) {
                                      trailer = null;
                                    }
                                  }
                                  if (trailer == null) return null;
                                  return () => launchUrlString(
                                    'https://www.youtube.com/watch?v=${trailer!.key}',
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                orElse: () => null,
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Trailer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white12,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Set Reminder button
                          if (btnVis['setReminder'] == true) ...[
                            Consumer(
                              builder: (context, ref, child) {
                                final reminderService = ReminderService();
                                final hasReminders = reminderService
                                    .hasRemindersForMovie(key);

                                return OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ScheduleScreen(
                                          watchlistItemId: key,
                                          movieTitle: title,
                                          moviePosterUrl: posterUrl.isNotEmpty
                                              ? posterUrl
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    hasReminders
                                        ? Icons.schedule
                                        : Icons.schedule_outlined,
                                    color: hasReminders
                                        ? Colors.white
                                        : Colors.white,
                                  ),
                                  label: Text(
                                    hasReminders ? 'Scheduled' : 'Set Reminder',
                                    style: TextStyle(
                                      color: hasReminders
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: hasReminders
                                        ? const Color(0xFF667eea)
                                        : Colors.transparent,
                                    side: BorderSide(
                                      color: hasReminders
                                          ? const Color(0xFF667eea)
                                          : Colors.white24,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Add to Watchlist button
                          if (btnVis['addToWatchlist'] == true) ...[
                            OutlinedButton.icon(
                              onPressed: () => ref
                                  .read(watchlistProvider.notifier)
                                  .toggle(key),
                              icon: Icon(
                                inWatchlist
                                    ? Icons.bookmark
                                    : Icons.bookmark_add_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                inWatchlist
                                    ? 'In Watchlist'
                                    : 'Add to Watchlist',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Watch Movie button (for movies only)
                          if (type == 'movie' && btnVis['watchMovie'] == true)
                            OutlinedButton.icon(
                              onPressed: () async {
                                // Show confirmation dialog first
                                final shouldProceed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF1A1D29),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Row(
                                        children: [
                                          Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.red,
                                            size: 32,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Watch Movie',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                        'Please watch a short ad to continue watching this movie.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 48,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Watch Ad',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldProceed == true && context.mounted) {
                                  // Show rewarded ad before watching movie
                                  final adService = AdService();
                                  final rewardEarned = await adService
                                      .showRewardedAd();

                                  if (rewardEarned && context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => WatchScreen(
                                          movieId: id,
                                          title: title,
                                          isTvShow: false,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.yellow,
                                size: 24,
                              ),
                              label: const Text(
                                'Start Watching',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.yellow),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),

                          // Watch Series button (for TV series only)
                          if (type == 'tv' && btnVis['watchSeries'] == true)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SeasonsScreen(
                                      tvId: id,
                                      seriesTitle: title,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.yellow,
                                size: 24,
                              ),
                              label: const Text(
                                'Start Watching',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.yellow),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      loading: () => const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 100),
                          Center(child: CircularProgressIndicator()),
                        ],
                      ),
                      error: (_, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Show all buttons on error
                          ElevatedButton.icon(
                            onPressed: videos.maybeWhen(
                              data: (v) {
                                Video? trailer;
                                try {
                                  trailer = v.firstWhere(
                                    (x) =>
                                        (x.type.toLowerCase() == 'trailer' ||
                                            x.name.toLowerCase().contains(
                                              'trailer',
                                            )) &&
                                        x.isYouTube,
                                  );
                                } catch (_) {
                                  try {
                                    trailer = v.firstWhere((x) => x.isYouTube);
                                  } catch (_) {
                                    trailer = null;
                                  }
                                }
                                if (trailer == null) return null;
                                return () => launchUrlString(
                                  'https://www.youtube.com/watch?v=${trailer!.key}',
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              orElse: () => null,
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Watch Trailer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: credits.when(
                        data: (cast) => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length.clamp(0, 20),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final c = cast[index];
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: c.profileUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: c.profileUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.white12,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white38,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    c.character,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(
                          'Failed to load cast: $e',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Floating back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VideoFallback {
  static final none = _VideoNone();
}

class _VideoNone {
  const _VideoNone();
  String get key => '';
}
