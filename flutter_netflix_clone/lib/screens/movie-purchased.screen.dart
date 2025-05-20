import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoviePurchasedScreen extends StatefulWidget {
  @override
  _MoviPpurchasedScreenState createState() => _MoviPpurchasedScreenState();
}

class _MoviPpurchasedScreenState extends State<MoviePurchasedScreen> {
  final List<Map<String, String>> _movies = [
    {
      'title': 'Barbie',
      'posterUrl':
          'https://upload.wikimedia.org/wikipedia/en/0/0b/Barbie_2023_poster.jpg'
    },
    {
      'title': 'Beef',
      'posterUrl':
          'https://th.bing.com/th/id/OIP.yqUULPHdC1KsvzVEXyT-YwHaLH?w=184&h=276&c=7&r=0&o=5&pid=1.7'
    },
    {
      'title': 'The Killer',
      'posterUrl':
          'https://m.media-amazon.com/images/M/MV5BNmNjZjdlOGUtZGFlZS00NjhmLWFlNzYtY2U0YTBmYmE2ZWQyXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg'
    },
    {
      'title': 'Mosul',
      'posterUrl':
          'https://th.bing.com/th/id/OIP.eG-bZnPe-zTwkhh8AlKANQHaK2?w=184&h=270&c=7&r=0&o=5&pid=1.7'
    },
    {
      'title': 'Unlocked',
      'posterUrl':
          'https://th.bing.com/th/id/OIP.ImTiBMrjxhE63aoijKSUcgHaKj?w=124&h=180&c=7&r=0&o=5&pid=1.7'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: const Text(
          'Movie purchased',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  _movies[index]['posterUrl']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                  _movies[index]['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
