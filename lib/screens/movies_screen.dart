import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/tmdb_providers.dart';
import '../models/movie.dart';

class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});
  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> {
  final _scrollController = ScrollController();
  final _carouselController = CarouselSliderController();
  final _searchController = TextEditingController();
  int _currentCarouselIndex = 0;
  Timer? _autoScrollTimer;
  bool _carouselReady = false;

  // Section states
  final List<Movie> _trending = [];
  final List<Movie> _popular = [];
  final List<Movie> _nowPlaying = [];
  final List<Movie> _upcoming = [];
  final List<Movie> _topRated = [];
  int _pageTrending = 1,
      _pagePopular = 1,
      _pageNow = 1,
      _pageUpcoming = 1,
      _pageTop = 1;
  int _showTrending = 15,
      _showPopular = 15,
      _showNow = 15,
      _showUpcoming = 15,
      _showTop = 15;
  bool _loadingTrending = false,
      _loadingPopular = false,
      _loadingNow = false,
      _loadingUpcoming = false,
      _loadingTop = false;

  // Search results
  final List<Movie> _searchResults = [];
  int _searchPage = 1;
  int _showSearch = 15;
  bool _loadingSearch = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // Delay auto-scroll to ensure carousel is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startAutoScroll();
        }
      });
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_carouselReady || _trending.isEmpty) return;

      try {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Carousel not ready yet, skip this cycle
      }
    });
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _fetchTrending(),
      _fetchPopular(),
      _fetchNowPlaying(),
      _fetchUpcoming(),
      _fetchTopRated(),
    ]);
  }

  Future<void> _fetchTrending() async {
    if (_loadingTrending) return;
    _loadingTrending = true;
    final api = ref.read(tmdbServiceProvider);
    final res = await api.trendingMovies(page: _pageTrending);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _trending.addAll(list);
      _pageTrending++;
      _loadingTrending = false;
    });
  }

  Future<void> _fetchPopular() async {
    if (_loadingPopular) return;
    _loadingPopular = true;
    final api = ref.read(tmdbServiceProvider);
    final res = await api.popularMovies(page: _pagePopular);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _popular.addAll(list);
      _pagePopular++;
      _loadingPopular = false;
    });
  }

  Future<void> _fetchNowPlaying() async {
    if (_loadingNow) return;
    _loadingNow = true;
    final api = ref.read(tmdbServiceProvider);
    final res = await api.nowPlayingMovies(page: _pageNow);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _nowPlaying.addAll(list);
      _pageNow++;
      _loadingNow = false;
    });
  }

  Future<void> _fetchUpcoming() async {
    if (_loadingUpcoming) return;
    _loadingUpcoming = true;
    final api = ref.read(tmdbServiceProvider);
    final res = await api.upcomingMovies(page: _pageUpcoming);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _upcoming.addAll(list);
      _pageUpcoming++;
      _loadingUpcoming = false;
    });
  }

  Future<void> _fetchTopRated() async {
    if (_loadingTop) return;
    _loadingTop = true;
    final api = ref.read(tmdbServiceProvider);
    final res = await api.topRatedMovies(page: _pageTop);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _topRated.addAll(list);
      _pageTop++;
      _loadingTop = false;
    });
  }

  Future<void> _search(String q, {bool reset = false}) async {
    if (_loadingSearch) return;
    _loadingSearch = true;
    final api = ref.read(tmdbServiceProvider);
    if (reset) {
      _searchResults.clear();
      _searchPage = 1;
      _showSearch = 15;
    }
    final res = await api.searchMovies(q, page: _searchPage);
    final list = (res.data['results'] as List)
        .map((e) => Movie.fromJson(e))
        .toList();
    setState(() {
      _searchResults.addAll(list);
      _searchPage++;
      _loadingSearch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(movieSearchQueryProvider);
    // kick search fetch when query changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty && _searchResults.isEmpty && !_loadingSearch) {
        _search(query, reset: true);
      }
    });
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
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: _buildSearchBar(query),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  if (query.isEmpty) ...[
                    _buildHeroCarousel(),
                    const SizedBox(height: 32),
                    _buildSection(
                      'Trending',
                      _trending.take(_showTrending).toList(),
                      () async {
                        setState(() {
                          _showTrending += 15;
                        });
                        if (_showTrending > _trending.length)
                          await _fetchTrending();
                      },
                    ),
                    _buildSection(
                      'Popular',
                      _popular.take(_showPopular).toList(),
                      () async {
                        setState(() {
                          _showPopular += 15;
                        });
                        if (_showPopular > _popular.length)
                          await _fetchPopular();
                      },
                    ),
                    _buildSection(
                      'Newest',
                      _nowPlaying.take(_showNow).toList(),
                      () async {
                        setState(() {
                          _showNow += 15;
                        });
                        if (_showNow > _nowPlaying.length)
                          await _fetchNowPlaying();
                      },
                    ),
                    _buildSection(
                      'Coming Soon',
                      _upcoming.take(_showUpcoming).toList(),
                      () async {
                        setState(() {
                          _showUpcoming += 15;
                        });
                        if (_showUpcoming > _upcoming.length)
                          await _fetchUpcoming();
                      },
                    ),
                    _buildSection(
                      'Top Rated',
                      _topRated.take(_showTop).toList(),
                      () async {
                        setState(() {
                          _showTop += 15;
                        });
                        if (_showTop > _topRated.length) await _fetchTopRated();
                      },
                    ),
                  ] else ...[
                    _buildSection(
                      'Search Results',
                      _searchResults.take(_showSearch).toList(),
                      () async {
                        setState(() {
                          _showSearch += 15;
                        });
                        if (_showSearch > _searchResults.length)
                          await _search(query);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(String query) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      ref.read(movieSearchQueryProvider.notifier).state = v;
                      if (v.isEmpty) {
                        setState(() {
                          _searchResults.clear();
                        });
                      } else {
                        _search(v, reset: true);
                      }
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(movieSearchQueryProvider.notifier).state = '';
                      setState(() {
                        _searchResults.clear();
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  )
                else
                  Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    if (_trending.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final carouselItems = _trending.take(10).toList();

    // Mark carousel as ready after first build
    if (!_carouselReady && carouselItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _carouselReady = true);
        }
      });
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: carouselItems.length,
          options: CarouselOptions(
            height: 280,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() => _currentCarouselIndex = index);
              // Mark as ready after first page change
              if (!_carouselReady && mounted) {
                setState(() => _carouselReady = true);
              }
            },
          ),
          itemBuilder: (context, index, _) {
            final movie = carouselItems[index];
            return _buildCarouselCard(movie);
          },
        ),
        const SizedBox(height: 16),
        _buildCarouselIndicators(carouselItems.length),
      ],
    );
  }

  Widget _buildCarouselCard(Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/details/movie/${movie.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: movie.backdropUrl.isNotEmpty
                    ? movie.backdropUrl
                    : movie.posterUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.black,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _currentCarouselIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSection(String title, List<Movie> items, VoidCallback onMore) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == items.length) return _buildShowMoreCard(onMore);
                return _buildMovieCard(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/details/movie/${movie.id}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: movie.posterUrl, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.black,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Show More',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
