import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_netflix_clone/providers/auth.provider.dart';
import 'package:flutter_netflix_clone/providers/movie.provider.dart';
import 'package:flutter_netflix_clone/providers/watchlist.provider.dart';
import 'package:flutter_netflix_clone/providers/comment.provider.dart';
import 'routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: MaterialApp.router(
        title: 'Netflix Clone',
        theme: ThemeData(
          primaryColor: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}