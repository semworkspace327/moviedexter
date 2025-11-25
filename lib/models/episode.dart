class Episode {
  final int id;
  final String name;
  final String overview;
  final String? stillPath;
  final int episodeNumber;
  final int seasonNumber;
  final String? airDate;
  final double voteAverage;
  final int runtime;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    this.stillPath,
    required this.episodeNumber,
    required this.seasonNumber,
    this.airDate,
    required this.voteAverage,
    required this.runtime,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'],
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      airDate: json['air_date'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
    );
  }

  String get stillUrl => stillPath != null 
      ? 'https://image.tmdb.org/t/p/w500$stillPath' 
      : '';
}
