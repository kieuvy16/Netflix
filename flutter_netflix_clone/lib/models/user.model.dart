class UserModel {
  final String id;
  final String username;
  final String email;
  final String? birthDate;
  final String? avatar;
  final String role;
  final List<dynamic> watchLater;
  final List<dynamic> favorites;
  final List<dynamic> purchasedMovies;
  final List<dynamic> preferences;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.birthDate,
    this.avatar,
    required this.role,
    required this.watchLater,
    required this.favorites,
    required this.purchasedMovies,
    required this.preferences,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birthDate']?.toString(),
      avatar: json['avatar']?.toString(),
      role: json['role'] ?? 'user',
      watchLater: json['watchLater'] ?? [],
      favorites: json['favorites'] ?? [],
      purchasedMovies: json['purchasedMovies'] ?? [],
      preferences: json['preferences'] ?? [],
      isActive: json['isActive'] ?? true,
    );
  }
}