class GenreModel {
  final String id;
  final String name;

  GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['_id'],
      name: json['name'],
    );
  }
}