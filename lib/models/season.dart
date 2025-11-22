class Season {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final int seasonNumber;
  final int episodeCount;
  final String? airDate;

  Season({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    this.airDate,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
      airDate: json['air_date'],
    );
  }

  String get posterUrl => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
      : '';
}
