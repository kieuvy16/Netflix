import 'package:flutter_netflix_clone/screens/coming-soon.screen.dart';
import 'package:flutter_netflix_clone/screens/movie-purchased.screen.dart';
import 'package:flutter_netflix_clone/screens/home.screen.dart';
import 'package:flutter_netflix_clone/screens/authentication/login.screen.dart';
import 'package:flutter_netflix_clone/screens/menu.screen.dart';
import 'package:flutter_netflix_clone/screens/movie-detail.screen.dart';
import 'package:flutter_netflix_clone/screens/payment.screen.dart';
import 'package:flutter_netflix_clone/screens/play-movie.screen.dart';
import 'package:flutter_netflix_clone/screens/profile.screen.dart';
import 'package:flutter_netflix_clone/screens/authentication/register.screen.dart';
import 'package:flutter_netflix_clone/screens/search.screen.dart';
import 'package:flutter_netflix_clone/screens/favorite-movie.screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth.provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    if (!isAuthenticated &&
        state.uri.toString() != '/login' &&
        state.uri.toString() != '/register' &&
        state.uri.toString() != '/forgot-password') {
      return '/login';
    }
    if (isAuthenticated &&
        (state.uri.toString() == '/login' || state.uri.toString() == '/register')) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/favorite',
      builder: (context, state) => FavoriteMovieScreen(),
    ),
    GoRoute(
      path: '/movie-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MovieDetailScreen(movieId: id);
      },
    ),
    GoRoute(
      path: '/play-movie/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlayMovieScreen(movieId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/payment/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PaymentScreen(movieId: id);
      },
    ),
    GoRoute(
      path: '/coming-soon',
      builder: (context, state) => const ComingSoonScreen(),
    ),
    GoRoute(
      path: '/purchas',
      builder: (context, state) => MoviePurchasedScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
  ],
);