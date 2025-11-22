class Credit {
  Credit({required this.id, required this.name, required this.profilePath, required this.character});
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  String get profileUrl => profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';

  factory Credit.fromJson(Map<String, dynamic> json) => Credit(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        profilePath: json['profile_path'] as String?,
        character: json['character'] as String? ?? '',
      );
}
