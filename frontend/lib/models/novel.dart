class Novel {
  final int id;
  final String title;
  final String author;
  final String genre;
  final String tropes;
  final String imageUrl;
  final String synopsis;
  final double rating;
  final int ratedBy;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.tropes,
    required this.imageUrl,
    required this.synopsis,
    required this.rating,
    required this.ratedBy,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json["id"],
      title: json["title"] ?? "",
      author: json["author"] ?? "",
      genre: json["genre"] ?? "",
      tropes: json["tropes"]?? "",
      imageUrl: json["imageUrl"] ?? "",
      synopsis: json["synopsis"] ?? "",
      rating: json["rating"] == null
          ? 0.0
          : double.tryParse(json["rating"].toString()) ?? 0.0,
      ratedBy: json["ratedBy"] ?? 0,
    );
  }
}
