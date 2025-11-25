import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/tmdb_providers.dart';
import '../models/season.dart';
import '../models/episode.dart';
import '../screens/watch_screen.dart';
import '../services/ad_service.dart';

class SeasonsScreen extends ConsumerStatefulWidget {
  const SeasonsScreen({
    super.key,
    required this.tvId,
    required this.seriesTitle,
  });

  final int tvId;
  final String seriesTitle;

  @override
  ConsumerState<SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends ConsumerState<SeasonsScreen> {
  Season? _selectedSeason;

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(tvSeasonsProvider(widget.tvId));
    final detailsAsync = ref.watch(
      detailsProvider((id: widget.tvId, type: 'tv')),
    );

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
        extendBodyBehindAppBar: true,
        body: detailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Column(
            children: [
              AppBar(
                title: Text(
                  _selectedSeason != null
                      ? '${widget.seriesTitle} - ${_selectedSeason!.name}'
                      : widget.seriesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (_selectedSeason != null) {
                      setState(() {
                        _selectedSeason = null;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Error loading seasons',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          data: (details) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  _selectedSeason != null
                      ? '${widget.seriesTitle} - ${_selectedSeason!.name}'
                      : widget.seriesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (_selectedSeason != null) {
                      setState(() {
                        _selectedSeason = null;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              body: _selectedSeason != null
                  ? _buildEpisodesList(_selectedSeason!)
                  : _buildSeasonsList(seasonsAsync),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeasonsList(AsyncValue<List<Season>> seasonsAsync) {
    return seasonsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading seasons: $error',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
      data: (seasons) {
        if (seasons.isEmpty) {
          return const Center(
            child: Text(
              'No seasons available',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            16,
            16,
          ),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return _SeasonCard(
              season: season,
              onTap: () {
                setState(() {
                  _selectedSeason = season;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEpisodesList(Season season) {
    final episodesAsync = ref.watch(
      tvSeasonEpisodesProvider((
        tvId: widget.tvId,
        seasonNumber: season.seasonNumber,
      )),
    );

    return episodesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading episodes: $error',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
      data: (episodes) {
        if (episodes.isEmpty) {
          return const Center(
            child: Text(
              'No episodes available',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            16,
            16,
          ),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return _EpisodeCard(
              episode: episode,
              tvId: widget.tvId,
              seriesTitle: widget.seriesTitle,
              seasonNumber: season.seasonNumber,
            );
          },
        );
      },
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season, required this.onTap});

  final Season season;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Season Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: season.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: season.posterUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 120,
                          color: Colors.white12,
                          child: const Icon(
                            Icons.tv,
                            color: Colors.white38,
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Season Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${season.episodeCount} episodes',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      if (season.airDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          season.airDate!,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (season.overview.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          season.overview,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white60,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    required this.tvId,
    required this.seriesTitle,
    required this.seasonNumber,
  });

  final Episode episode;
  final int tvId;
  final String seriesTitle;
  final int seasonNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
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
                        'Watch Episode',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Please watch a short ad to continue watching this episode.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
              // Show rewarded ad before watching episode
              final adService = AdService();
              final rewardEarned = await adService.showRewardedAd();

              if (rewardEarned && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WatchScreen(
                      movieId: tvId,
                      title:
                          '$seriesTitle - S${seasonNumber}E${episode.episodeNumber}',
                      season: seasonNumber,
                      episode: episode.episodeNumber,
                      isTvShow: true,
                    ),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D29),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Episode Still/Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: episode.stillUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: episode.stillUrl,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 68,
                          color: Colors.white12,
                          child: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white38,
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Episode Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'E${episode.episodeNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (episode.runtime > 0)
                            Text(
                              '${episode.runtime}min',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        episode.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (episode.overview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          episode.overview,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (episode.airDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          episode.airDate!,
                          style: const TextStyle(
                            color: Color(0x80FFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
