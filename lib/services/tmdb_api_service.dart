import 'package:dio/dio.dart';

class TmdbApiService {
  TmdbApiService([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey =
      'e794ccd60488962d067044c54100e665'; // replace with your TMDB API key

  final Dio _dio;

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final q = {
      'api_key': apiKey,
      'language': 'en-US',
      'include_adult': false, // Filter adult content globally
      ...?query,
    };
    return _dio.get(path, queryParameters: q);
  }

  // Stubs to be implemented
  Future<Response> trendingAll({int page = 1}) =>
      _get('/trending/all/day', query: {'page': page});
  Future<Response> trendingMovies({int page = 1}) =>
      _get('/trending/movie/day', query: {'page': page});
  Future<Response> topRatedMovies({int page = 1}) =>
      _get('/movie/top_rated', query: {'page': page});
  Future<Response> upcomingMovies({int page = 1}) =>
      _get('/movie/upcoming', query: {'page': page});
  Future<Response> nowPlayingMovies({int page = 1}) =>
      _get('/movie/now_playing', query: {'page': page});
  Future<Response> popularMovies({int page = 1}) =>
      _get('/movie/popular', query: {'page': page});
  Future<Response> popularTV({int page = 1}) =>
      _get('/tv/popular', query: {'page': page});
  Future<Response> trendingTV({int page = 1}) =>
      _get('/trending/tv/week', query: {'page': page});
  Future<Response> topRatedTV({int page = 1}) =>
      _get('/tv/top_rated', query: {'page': page});
  Future<Response> onAirTV({int page = 1}) =>
      _get('/tv/on_the_air', query: {'page': page});
  Future<Response> searchMovies(String query, {int page = 1}) => _get(
    '/search/movie',
    query: {'query': query, 'page': page, 'include_adult': false},
  );
  Future<Response> searchTV(String query, {int page = 1}) => _get(
    '/search/tv',
    query: {'query': query, 'page': page, 'include_adult': false},
  );
  Future<Response> movieDetails(int id) => _get('/movie/$id');
  Future<Response> tvDetails(int id) => _get('/tv/$id');
  Future<Response> movieCredits(int id) => _get('/movie/$id/credits');
  Future<Response> tvCredits(int id) => _get('/tv/$id/credits');
  Future<Response> movieVideos(int id) => _get('/movie/$id/videos');
  Future<Response> tvVideos(int id) => _get('/tv/$id/videos');
  Future<Response> tvSeason(int tvId, int seasonNumber) =>
      _get('/tv/$tvId/season/$seasonNumber');
}
