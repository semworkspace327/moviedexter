import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/tmdb_api_service.dart';
import '../models/movie.dart';
import '../models/video.dart';
import '../models/credit.dart';
import '../models/season.dart';
import '../models/episode.dart';

final tmdbServiceProvider = Provider<TmdbApiService>((ref) => TmdbApiService());

final trendingProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final api = ref.read(tmdbServiceProvider);
  final res = await api.trendingAll(page: 1);
  final list = (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  return list;
});

final topRatedMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final api = ref.read(tmdbServiceProvider);
  final res = await api.topRatedMovies(page: 1);
  return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
});

final upcomingMoviesProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final api = ref.read(tmdbServiceProvider);
  final res = await api.upcomingMovies(page: 1);
  return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
});

class PagedMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  PagedMoviesNotifier(this._api): super(const AsyncLoading());
  final TmdbApiService _api;
  int _page = 1;
  bool _hasMore = true;
  final List<Movie> _items = [];

  bool get hasMore => _hasMore;

  Future<void> refresh() async {
    _page = 1; _hasMore = true; _items.clear();
    state = const AsyncLoading();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    try {
      final res = await _api.popularMovies(page: _page);
      final newItems = (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
      _hasMore = newItems.isNotEmpty;
      if (_page == 1) {
        _items
          ..clear()
          ..addAll(newItems);
      } else {
        _items.addAll(newItems);
      }
      _page++;
      state = AsyncData(List.unmodifiable(_items));
    } on DioException catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final popularMoviesPagedProvider = StateNotifierProvider.autoDispose<PagedMoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final api = ref.read(tmdbServiceProvider);
  final notifier = PagedMoviesNotifier(api);
  notifier.refresh();
  return notifier;
});

final movieSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final movieSearchResultsProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final q = ref.watch(movieSearchQueryProvider);
  if (q.trim().isEmpty) return [];
  final api = ref.read(tmdbServiceProvider);
  final res = await api.searchMovies(q.trim(), page: 1);
  return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
});

// TV popular uses same Movie model mapping (title property maps name when needed)
class PagedTVNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  PagedTVNotifier(this._api): super(const AsyncLoading());
  final TmdbApiService _api;
  int _page = 1; bool _hasMore = true; final List<Movie> _items = [];
  bool get hasMore => _hasMore;
  Future<void> refresh() async { _page = 1; _hasMore = true; _items.clear(); state = const AsyncLoading(); await loadMore(); }
  Future<void> loadMore() async {
    if (!_hasMore) return;
    try {
      final res = await _api.popularTV(page: _page);
      final newItems = (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
      _hasMore = newItems.isNotEmpty; _items.addAll(newItems); _page++; state = AsyncData(List.unmodifiable(_items));
    } catch (e, st) { state = AsyncError(e, st); }
  }
}

final popularTVPagedProvider = StateNotifierProvider.autoDispose<PagedTVNotifier, AsyncValue<List<Movie>>>((ref) {
  final api = ref.read(tmdbServiceProvider);
  final notifier = PagedTVNotifier(api); notifier.refresh(); return notifier;
});

final tvSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final tvSearchResultsProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final q = ref.watch(tvSearchQueryProvider);
  if (q.trim().isEmpty) return [];
  final api = ref.read(tmdbServiceProvider);
  final res = await api.searchTV(q.trim(), page: 1);
  return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
});

final detailsVideosProvider = FutureProvider.family.autoDispose<List<Video>, ({int id, String type})>((ref, args) async {
  final api = ref.read(tmdbServiceProvider);
  final res = args.type == 'movie' ? await api.movieVideos(args.id) : await api.tvVideos(args.id);
  return (res.data['results'] as List).map((e) => Video.fromJson(e)).toList();
});

final detailsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, ({int id, String type})>((ref, args) async {
  final api = ref.read(tmdbServiceProvider);
  final res = args.type == 'movie' ? await api.movieDetails(args.id) : await api.tvDetails(args.id);
  return Map<String, dynamic>.from(res.data as Map);
});

final creditsProvider = FutureProvider.family.autoDispose<List<Credit>, ({int id, String type})>((ref, args) async {
  final api = ref.read(tmdbServiceProvider);
  final res = args.type == 'movie' ? await api.movieCredits(args.id) : await api.tvCredits(args.id);
  return (res.data['cast'] as List).map((e) => Credit.fromJson(e)).toList();
});

final tvSeasonsProvider = FutureProvider.family.autoDispose<List<Season>, int>((ref, tvId) async {
  final api = ref.read(tmdbServiceProvider);
  final res = await api.tvDetails(tvId);
  final seasons = (res.data['seasons'] as List? ?? []).map((e) => Season.fromJson(e)).toList();
  return seasons.where((season) => season.seasonNumber > 0).toList(); // Filter out specials (season 0)
});

final tvSeasonEpisodesProvider = FutureProvider.family.autoDispose<List<Episode>, ({int tvId, int seasonNumber})>((ref, args) async {
  final api = ref.read(tmdbServiceProvider);
  final res = await api.tvSeason(args.tvId, args.seasonNumber);
  return (res.data['episodes'] as List? ?? []).map((e) => Episode.fromJson(e)).toList();
});
