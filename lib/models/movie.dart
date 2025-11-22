class Movie {
  Movie({required this.id, required this.title, required this.posterPath, required this.backdropPath, required this.voteAverage, required this.releaseDate, required this.overview, required this.genreIds});
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final String overview;
  final List<int> genreIds;

  String get posterUrl => posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get backdropUrl => backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json['id'] as int,
        title: (json['title'] ?? json['name'] ?? '') as String,
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
        releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
        overview: json['overview'] as String? ?? '',
        genreIds: (json['genre_ids'] as List?)?.map((e) => e as int).toList() ?? const [],
      );
}
