class ApiConfig {
  static const String movies = '/api/movie';
  static const String genres = '/api/genre';
  static const String user = '/api/user';
  static const String login = '/api/user/login';
  static const String register = '/api/user/register';
  static const String movieById = '/api/movie/:id';
  static const String userMovies = '/api/movie/user/:id';
  static const String favorites = '/api/movie/favorites';
  static const String purchasedMovies = '/api/movie/purchasedMovies';
  static const String payment = '/api/movie/payment/:id';
  static const String searchMovies = '/api/movie/search';
  static const String comments = '/api/comments';
  static const String commentsByMovie = '/api/comments/movie/:movieId';
  static const String commentById = '/api/comments/:commentId';
  static const String downloads = '/api/downloads';

  static String withId(String endpoint, String id) {
    return endpoint.replaceFirst(':id', id);
  }
}