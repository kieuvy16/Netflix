class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String? avatar;
  final String movieId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatar,
    required this.movieId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      userId: user != null ? user['_id']?.toString() ?? '' : '',
      username: user != null ? user['username']?.toString() ?? '' : '',
      avatar: user != null ? user['avatar']?.toString() : null,
      movieId: json['movie']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': {'_id': userId, 'username': username, 'avatar': avatar},
      'movie': movieId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      
    };
    
  }
}