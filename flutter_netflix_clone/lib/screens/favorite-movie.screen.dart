import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/movie.model.dart';
import '../providers/auth.provider.dart';
import '../providers/watchlist.provider.dart';

class FavoriteMovieScreen extends StatefulWidget {
  const FavoriteMovieScreen({Key? key}) : super(key: key);

  @override
  _FavoriteMovieScreenState createState() => _FavoriteMovieScreenState();
}

class _FavoriteMovieScreenState extends State<FavoriteMovieScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final watchlistProvider =
        Provider.of<WatchlistProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (authProvider.token == null) {
        await authProvider.logout();
        context.go('/login');
        return;
      }
      await watchlistProvider.fetchFavorites(authProvider.token!);
    } catch (e) {
      if (e.toString().contains('Invalid movie ID') ||
          e.toString().contains('Không tìm thấy phim')) {
      } else if (e.toString().contains('Invalid Token')) {
        // errorMessage = 'Session expired';
        await authProvider.logout();
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final List<MovieModel> favoriteMovies = watchlistProvider.favorites;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: const Text(
          'Favorite List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: watchlistProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : favoriteMovies.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite movies yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = favoriteMovies[index];
                    return GestureDetector(
                      onTap: () {
                        context.push('/movie-detail/${movie.id}');
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              movie.thumbnail,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        color: Colors.red, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Không tải được hình ảnh',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            left: 8.0,
                            right: 8.0,
                            child: Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
