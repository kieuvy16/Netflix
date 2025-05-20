import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/models/movie.model.dart';
import 'package:flutter_netflix_clone/providers/auth.provider.dart';
// ignore: depend_on_referenced_packages
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/movie.provider.dart';
import '../providers/watchlist.provider.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<MovieModel>> _moviesByGenre = {};
  MovieModel? _randomFreeMovie;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    await movieProvider.fetchGenres();
    await movieProvider.fetchFreeMovies();
    await movieProvider.fetchMovies();

    if (movieProvider.freeMovies.isNotEmpty) {
      final random = Random();
      _randomFreeMovie = movieProvider
          .freeMovies[random.nextInt(movieProvider.freeMovies.length)];
    }

    for (var genre in movieProvider.genres) {
      final movies = await movieProvider.fetchMoviesByGenre(genre.id);
      _moviesByGenre[genre.id] = movies;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context, listen: true);
    final watchlistProvider =
        Provider.of<WatchlistProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo-home.png',
              height: 50,
              width: 50,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: _randomFreeMovie != null &&
                              _randomFreeMovie!.thumbnail.isNotEmpty
                          ? NetworkImage(_randomFreeMovie!.thumbnail)
                          : const NetworkImage(
                              'https://via.placeholder.com/400x600.png?text=Movie+Background'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  clipBehavior:
                      Clip.antiAlias, 
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _randomFreeMovie != null
                                  ? '#${movieProvider.freeMovies.indexOf(_randomFreeMovie!) + 1} in Nigeria Today'
                                  : '#2 in Nigeria Today',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline,
                                  color: Colors.white),
                              onPressed: () {
                                if (_randomFreeMovie != null) {
                                  context.push(
                                      '/movie-detail/${_randomFreeMovie!.id}');
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.white),
                              onPressed: () async {
                                if (_randomFreeMovie != null) {
                                  try {
                                    final token = Provider.of<AuthProvider>(
                                            context,
                                            listen: false)
                                        .token;
                                    await watchlistProvider.addToFavorites(
                                        _randomFreeMovie!.id, token!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Added to favorites')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Row(
                                children: [
                                  Text('Coming Soon',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Phần Previews
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Previews',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  movieProvider.freeMovies.isEmpty
                      ? const Text(
                          'No free movies available',
                          style: TextStyle(color: Colors.white),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: movieProvider.freeMovies.map((movie) {
                              return PreviewCard(movie: movie);
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
            if (movieProvider.genres.isNotEmpty)
              ...movieProvider.genres.map((genre) {
                final movies = _moviesByGenre[genre.id] ?? [];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      movies.isEmpty
                          ? Text(
                              'No movies available for ${genre.name}',
                              style: const TextStyle(color: Colors.white),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: movies.map((movie) {
                                  return MovieCard(movie: movie);
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF333333))),
          color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(Icons.home, "Home", true, () => context.go('/home')),
            _bottomNavItem(
                Icons.search, "Search", false, () => context.go('/search')),
            _bottomNavItem(Icons.filter_list, "Movie List", false,
                () => _showMovieListMenu(context)),
            _bottomNavItem(
                Icons.menu, "Menu", false, () => context.go('/menu')),
          ],
        ),
      ),
    );
  }
}

class PreviewCard extends StatelessWidget {
  final MovieModel movie;

  const PreviewCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          context.push('/movie-detail/${movie.id}');
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: movie.thumbnail.isNotEmpty
                  ? NetworkImage(movie.thumbnail)
                  : const NetworkImage('https://via.placeholder.com/100.png'),
              onBackgroundImageError: (exception, stackTrace) {},
              child: movie.thumbnail.isEmpty
                  ? const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/100.png'),
                    )
                  : null,
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 100,
              child: Text(
                movie.title,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final MovieModel movie;

  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          context.push('/movie-detail/${movie.id}');
        },
        child: Container(
          width: 150,
          height: 225,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: movie.thumbnail.isNotEmpty
                  ? NetworkImage(movie.thumbnail)
                  : const NetworkImage(
                      'https://via.placeholder.com/150x225.png'),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {},
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              movie.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _bottomNavItem(
    IconData icon, String label, bool active, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Colors.white : Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: active ? Colors.white : Colors.grey, fontSize: 12),
        ),
      ],
    ),
  );
}

void _showMovieListMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text("Movie purchased",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.go('/purchas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.white),
              title: const Text("Movie Favorite",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.go('/favorite');
              },
            ),
          ],
        ),
      );
    },
  );
}
