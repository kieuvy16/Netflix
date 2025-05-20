import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/services/api.service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/movie.model.dart';
import '../providers/movie.provider.dart';
import '../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<MovieModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await context.read<MovieProvider>().searchMovies(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      String message = 'An error occurred while searching.';
      if (e is ApiException && e.statusCode == 400) {
        message = e.message;
      } else if (e is ApiException) {
        message = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search movies, genres...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: AppConstants.darkGrey,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: _isSearching
          ? const Center(
              child: CircularProgressIndicator(color: AppConstants.primary),
            )
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Enter a movie title to search'
                        : 'No movies found',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildMovieItem(_searchResults[index]);
                  },
                ),
    );
  }

  Widget _buildMovieItem(MovieModel movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          print('Movie ID: ${movie.id}');
          if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(movie.id)) {
            context.push('/movie-detail/${movie.id}');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Invalid movie ID')),
            );
          }
        },
        child: Container(
          color: AppConstants.darkGrey,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  movie.thumbnail.isNotEmpty
                      ? movie.thumbnail
                      : 'https://via.placeholder.com/100x60',
                  width: 100.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://via.placeholder.com/100x60',
                      width: 100.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
