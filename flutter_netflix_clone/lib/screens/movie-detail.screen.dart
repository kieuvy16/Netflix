// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:provider/provider.dart';
// // import 'package:flutter_html/flutter_html.dart';
// // import '../models/movie.model.dart';
// // import '../providers/auth.provider.dart';
// // import '../providers/movie.provider.dart';
// // import '../providers/watchlist.provider.dart';

// // class MovieDetailScreen extends StatefulWidget {
// //   final String? movieId;
// //   const MovieDetailScreen({Key? key, this.movieId}) : super(key: key);

// //   @override
// //   State<MovieDetailScreen> createState() => _MovieDetailScreenState();
// // }

// // class _MovieDetailScreenState extends State<MovieDetailScreen> {
// //   bool isPlaying = false;
// //   MovieModel? movie;
// //   bool isLoading = true;
// //   bool isFavorite = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchMovieDetails();
// //   }

// //   Future<void> _fetchMovieDetails() async {
// //     try {
// //       final movieProvider = Provider.of<MovieProvider>(context, listen: false);
// //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //       final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);

// //       if (widget.movieId == null || widget.movieId!.isEmpty) {
// //         throw Exception('Movie ID is null or empty');
// //       }

// //       final fetchedMovie = await movieProvider.fetchMovieById(
// //         widget.movieId!,
// //         token: authProvider.token,
// //       );
// //       setState(() {
// //         movie = fetchedMovie;
// //         isLoading = false;
// //         isFavorite = watchlistProvider.favorites.any((fav) => fav.id == movie!.id);
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading movie details: $e')),
// //       );
// //     }
// //   }

// //   Future<void> _toggleFavorite() async {
// //     try {
// //       final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
// //       final authProvider = Provider.of<AuthProvider>(context, listen: false);

// //       if (isFavorite) {
// //         await watchlistProvider.removeFromFavorites(movie!.id, authProvider.token!);
// //         setState(() {
// //           isFavorite = false;
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Removed from favorites')),
// //         );
// //       } else {
// //         await watchlistProvider.addToFavorites(movie!.id, authProvider.token!);
// //         setState(() {
// //           isFavorite = true;
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Added to favorites')),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Lỗi: $e')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: Colors.black,
// //         elevation: 0,
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         title: Text(
// //           movie?.title ?? 'Movie details',
// //           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : movie == null
// //               ? const Center(child: Text('Movie not found', style: TextStyle(color: Colors.white)))
// //               : SingleChildScrollView(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Poster = hình ảnh của phim
// //                       Center(
// //                         child: ClipRRect(
// //                           borderRadius: BorderRadius.circular(12),
// //                           child: Image.network(
// //                             movie!.thumbnail,
// //                             width: double.infinity,
// //                             height: MediaQuery.of(context).size.width * 0.56,
// //                             fit: BoxFit.cover,
// //                             filterQuality: FilterQuality.high,
// //                             errorBuilder: (context, error, stackTrace) => Image.network(
// //                               'https://via.placeholder.com/400x224.png?text=Movie+Poster',
// //                               fit: BoxFit.cover,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),

// //                       // Poster Info
// //                       Padding(
// //                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 ElevatedButton.icon(
// //                                   onPressed: movie!.isPaid
// //                                       ? () {
// //                                           context.push('/play-movie/${movie!.id}');
// //                                         }
// //                                       : null,
// //                                   icon: Icon(
// //                                     movie!.isPaid ? Icons.play_arrow : Icons.lock,
// //                                     color: const Color.fromARGB(255, 205, 85, 0),
// //                                   ),
// //                                   label: Text(
// //                                     movie!.isPaid ? 'Play' : 'Comming soon',
// //                                     style: const TextStyle(
// //                                       color: Color.fromARGB(255, 158, 0, 0),
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: Colors.white,
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 18,
// //                                       vertical: 8,
// //                                     ),
// //                                     elevation: 0,
// //                                   ),
// //                                 ),
// //                                 Row(
// //                                   children: [
// //                                     Container(
// //                                       decoration: const BoxDecoration(
// //                                         color: Colors.white,
// //                                         shape: BoxShape.circle,
// //                                       ),
// //                                       child: IconButton(
// //                                         icon: const Icon(Icons.share_outlined,
// //                                             color: Colors.black, size: 20),
// //                                         onPressed: () {
// //                                           // TODO: chia sẻ
// //                                         },
// //                                       ),
// //                                     ),
// //                                     const SizedBox(width: 8),
// //                                     Container(
// //                                       decoration: const BoxDecoration(
// //                                         color: Colors.white,
// //                                         shape: BoxShape.circle,
// //                                       ),
// //                                       child: IconButton(
// //                                         icon: Icon(
// //                                           isFavorite ? Icons.favorite : Icons.favorite_border,
// //                                           color: Colors.black,
// //                                           size: 20,
// //                                         ),
// //                                         onPressed: _toggleFavorite,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 16),
// //                             Text(
// //                               'Ngày phát hành: ${movie!.formattedCreatedAt}',
// //                               style: const TextStyle(color: Colors.white70, fontSize: 14),
// //                             ),
// //                             const SizedBox(height: 6),
// //                             Text(
// //                               'Thể loại: ${movie!.genreName}',
// //                               style: const TextStyle(color: Colors.white70, fontSize: 14),
// //                             ),
// //                             const SizedBox(height: 6),
// //                             Text(
// //                               movie!.title,
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 22,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             // description
// //                             Html(
// //                               data: movie!.description ?? 'No description available',
// //                               style: {
// //                                 'body': Style(
// //                                   color: Colors.white70,
// //                                   fontSize: FontSize(14),
// //                                 ),
// //                               },
// //                             ),
// //                             const SizedBox(height: 10),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_html/flutter_html.dart';
// import '../models/movie.model.dart';
// import '../providers/auth.provider.dart';
// import '../providers/movie.provider.dart';
// import '../providers/watchlist.provider.dart';

// class MovieDetailScreen extends StatefulWidget {
//   final String? movieId;
//   const MovieDetailScreen({Key? key, this.movieId}) : super(key: key);

//   @override
//   State<MovieDetailScreen> createState() => _MovieDetailScreenState();
// }

// class _MovieDetailScreenState extends State<MovieDetailScreen> {
//   MovieModel? movie;
//   bool isLoading = true;
//   bool isFavorite = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMovieDetails();
//   }

//   Future<void> _fetchMovieDetails() async {
//     try {
//       final movieProvider = Provider.of<MovieProvider>(context, listen: false);
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);

//       if (widget.movieId == null || widget.movieId!.isEmpty) {
//         throw Exception('Movie ID is null or empty');
//       }

//       // Lấy dữ liệu phim
//       final fetchedMovie = await movieProvider.fetchMovieById(
//         widget.movieId!,
//         token: authProvider.token,
//       );

//       setState(() {
//         movie = fetchedMovie;
//         isLoading = false;
//         isFavorite = watchlistProvider.favorites.any((fav) => fav.id == movie!.id);
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading movie details: $e')),
//       );
//     }
//   }

//   Future<void> _toggleFavorite() async {
//     try {
//       final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       if (movie == null) return;

//       if (isFavorite) {
//         await watchlistProvider.removeFromFavorites(movie!.id, authProvider.token!);
//         setState(() {
//           isFavorite = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Removed from favorites')),
//         );
//       } else {
//         await watchlistProvider.addToFavorites(movie!.id, authProvider.token!);
//         setState(() {
//           isFavorite = true;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Added to favorites')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           movie?.title ?? 'Movie details',
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : movie == null
//               ? const Center(child: Text('Movie not found', style: TextStyle(color: Colors.white)))
//               : SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Poster hình ảnh phim
//                       Center(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             movie!.thumbnail,
//                             width: double.infinity,
//                             height: MediaQuery.of(context).size.width * 0.56,
//                             fit: BoxFit.cover,
//                             filterQuality: FilterQuality.high,
//                             errorBuilder: (context, error, stackTrace) => Image.network(
//                               'https://via.placeholder.com/400x224.png?text=Movie+Poster',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Thông tin phim
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Nút play và chia sẻ + favorite
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 ElevatedButton.icon(
//                                   onPressed: movie!.isPaid
//                                       ? () {
//                                           context.push('/play-movie/${movie!.id}');
//                                         }
//                                       : null,
//                                   icon: Icon(
//                                     movie!.isPaid ? Icons.play_arrow : Icons.lock,
//                                     color: const Color.fromARGB(255, 205, 85, 0),
//                                   ),
//                                   label: Text(
//                                     movie!.isPaid ? 'Play' : 'Comming soon',
//                                     style: const TextStyle(
//                                       color: Color.fromARGB(255, 158, 0, 0),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 18,
//                                       vertical: 8,
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     // Nút chia sẻ (bạn có thể xử lý thêm)
//                                     Container(
//                                       decoration: const BoxDecoration(
//                                         color: Colors.white,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: IconButton(
//                                         icon: const Icon(Icons.share_outlined,
//                                             color: Colors.black, size: 20),
//                                         onPressed: () {
//                                           // TODO: Xử lý chia sẻ phim
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     // Nút yêu thích
//                                     Container(
//                                       decoration: const BoxDecoration(
//                                         color: Colors.white,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: IconButton(
//                                         icon: Icon(
//                                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                                           color: Colors.black,
//                                           size: 20,
//                                         ),
//                                         onPressed: _toggleFavorite,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'Ngày phát hành: ${movie!.formattedCreatedAt}',
//                               style: const TextStyle(color: Colors.white70, fontSize: 14),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               'Thể loại: ${movie!.genreName}',
//                               style: const TextStyle(color: Colors.white70, fontSize: 14),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               movie!.title,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             // Mô tả phim (dùng flutter_html)
//                             Html(
//                               data: movie!.description ?? 'No description available',
//                               style: {
//                                 'body': Style(
//                                   color: Colors.white70,
//                                   fontSize: FontSize(14),
//                                 ),
//                               },
//                             ),
//                             const SizedBox(height: 10),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

import '../models/movie.model.dart';
import '../providers/auth.provider.dart';
import '../providers/movie.provider.dart';
import '../providers/watchlist.provider.dart';
import '../widgets/comment_section.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? movieId;
  const MovieDetailScreen({Key? key, this.movieId}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieModel? movie;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);

      if (widget.movieId == null || widget.movieId!.isEmpty) {
        throw Exception('Movie ID is null or empty');
      }

      final fetchedMovie = await movieProvider.fetchMovieById(
        widget.movieId!,
        token: authProvider.token,
      );

      setState(() {
        movie = fetchedMovie;
        isLoading = false;
        isFavorite = watchlistProvider.favorites.any((fav) => fav.id == movie!.id);
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải phim: $e')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (movie == null) return;

    try {
      if (isFavorite) {
        await watchlistProvider.removeFromFavorites(movie!.id, authProvider.token!);
        setState(() => isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá khỏi danh sách yêu thích')),
        );
      } else {
        await watchlistProvider.addToFavorites(movie!.id, authProvider.token!);
        setState(() => isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào yêu thích')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          movie?.title ?? 'Chi tiết phim',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : movie == null
              ? const Center(child: Text('Không tìm thấy phim', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          movie!.thumbnail,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.network(
                            'https://via.placeholder.com/400x224.png?text=Movie+Poster',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: movie!.isPaid
                                      ? () {
                                          context.push('/play-movie/${movie!.id}');
                                        }
                                      : null,
                                  icon: Icon(
                                    movie!.isPaid ? Icons.play_arrow : Icons.lock,
                                    color: const Color.fromARGB(255, 205, 85, 0),
                                  ),
                                  label: Text(
                                    movie!.isPaid ? 'Xem phim' : 'Sắp ra mắt',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 158, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share, color: Colors.white),
                                      onPressed: () {
                                        // TODO: Chia sẻ
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: _toggleFavorite,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Ngày phát hành: ${movie!.formattedCreatedAt}',
                                style: const TextStyle(color: Colors.white70)),
                            Text('Thể loại: ${movie!.genreName}',
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 12),
                            Text(
                              movie!.title,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Html(
                              data: movie!.description ?? '',
                              style: {
                                "body": Style(color: Colors.white70),
                              },
                            ),
                            const SizedBox(height: 16),

                            // Comment section
                            CommentSection(movieId: movie!.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
