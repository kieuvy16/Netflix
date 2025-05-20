import 'package:intl/intl.dart';

class MovieModel {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String thumbnail;
  final String genreId;
  final String genreName;
  final bool isPaid;
  final double price;
  final DateTime? createdAt;

  MovieModel({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.genreId,
    required this.genreName,
    required this.isPaid,
    required this.price,
    this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString();
    if (id == null || id.isEmpty || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
      throw FormatException('Invalid movie ID: ${json['_id']}');
    }
    return MovieModel(
      id: id,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      genreId: json['genre'] != null ? json['genre']['_id']?.toString() ?? '' : '',
      genreName: json['genre'] != null ? json['genre']['name']?.toString() ?? '' : '',
      isPaid: json['isPaid'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  String get formattedCreatedAt {
    if (createdAt == null) return 'Chưa xác định';
    return DateFormat('dd/MM/yyyy').format(createdAt!);
  }
}