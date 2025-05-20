// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import '../models/movie.model.dart';
// import '../providers/auth.provider.dart';
// import '../providers/movie.provider.dart';

// class PlayMovieScreen extends StatefulWidget {
//   final String movieId;

//   const PlayMovieScreen({super.key, required this.movieId});

//   @override
//   State<PlayMovieScreen> createState() => _PlayMovieScreenState();
// }

// class _PlayMovieScreenState extends State<PlayMovieScreen> {
//   MovieModel? movie;
//   bool isLoading = true;
//   String? errorMessage;
//   YoutubePlayerController? _controller;
//   bool _isFullScreen = false;
//   bool _showAppBar = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMovieDetails();
//   }

//   Future<void> _fetchMovieDetails() async {
//     try {
//       final movieProvider = Provider.of<MovieProvider>(context, listen: false);
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       if (authProvider.token == null) {
//         await authProvider.logout();
//         context.go('/login');
//         return;
//       }

//       final fetchedMovie = await movieProvider.fetchMovieById(
//         widget.movieId,
//         token: authProvider.token,
//       );

//       if (fetchedMovie.videoUrl.isEmpty) {
//         throw Exception('Không tìm thấy URL video YouTube');
//       }

//       String videoId = YoutubePlayer.convertUrlToId(fetchedMovie.videoUrl) ?? fetchedMovie.videoUrl;

//       if (!RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoId)) {
//         throw Exception('ID video YouTube không hợp lệ');
//       }

//       _controller = YoutubePlayerController(
//         initialVideoId: videoId,
//         flags: const YoutubePlayerFlags(
//           autoPlay: true,
//           mute: false,
//           enableCaption: true,
//           loop: false,
//           forceHD: false,
//         ),
//       );

//       setState(() {
//         movie = fetchedMovie;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching movie: $e');
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Lỗi khi tải video';
//         if (e.toString().contains('Token không hợp lệ')) {
//           errorMessage = 'Phiên đăng nhập hết hạn';
//           Provider.of<AuthProvider>(context, listen: false).logout();
//           context.go('/login');
//         } else if (e.toString().contains('Không tìm thấy phim')) {
//           errorMessage = 'Phim không tồn tại';
//         } else if (e.toString().contains('URL video') || e.toString().contains('ID video')) {
//           errorMessage = 'Video không hợp lệ';
//         }
//       });
//     }
//   }

//   void _handleDoubleTap(bool isLeftSide) {
//     if (_controller == null) return;
//     final currentPosition = _controller!.value.position;
//     final newPosition = isLeftSide
//         ? currentPosition - const Duration(seconds: 10)
//         : currentPosition + const Duration(seconds: 10);
//     _controller!.seekTo(newPosition);
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

//     // Tính toán chiều cao tối đa dựa trên chiều rộng để giữ tỷ lệ 16/9
//     final videoWidth = _isFullScreen && isLandscape ? screenHeight : screenWidth;
//     final videoHeight = videoWidth * 9 / 16; // Tỷ lệ 16/9

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: _showAppBar
//           ? AppBar(
//               backgroundColor: Colors.black,
//               elevation: 0,
//               iconTheme: const IconThemeData(color: Colors.white),
//               title: Text(
//                 movie?.title ?? 'Phát phim',
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             )
//           : null,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.red))
//           : errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         errorMessage!,
//                         style: const TextStyle(color: Colors.white, fontSize: 16),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => context.go('/home'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         child: const Text(
//                           'Quay lại trang chủ',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : YoutubePlayerBuilder(
//                   player: YoutubePlayer(
//                     controller: _controller!,
//                     showVideoProgressIndicator: true,
//                     progressIndicatorColor: Colors.red,
//                     progressColors: const ProgressBarColors(
//                       playedColor: Colors.red,
//                       handleColor: Colors.white,
//                     ),
//                     onReady: () {
//                       _controller?.addListener(() {});
//                     },
//                     onEnded: (metaData) {
//                       context.pushReplacement('/movie-detail/${widget.movieId}');
//                     },
//                   ),
//                   onEnterFullScreen: () {
//                     setState(() {
//                       _isFullScreen = true;
//                       _showAppBar = false;
//                     });
//                   },
//                   onExitFullScreen: () {
//                     setState(() {
//                       _isFullScreen = false;
//                       _showAppBar = true;
//                     });
//                   },
//                   builder: (context, player) {
//                     return Center(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           maxWidth: videoWidth,
//                           maxHeight: _isFullScreen && isLandscape
//                               ? screenWidth
//                               : videoHeight.clamp(0, screenHeight - (_showAppBar ? kToolbarHeight : 0)),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 onDoubleTap: () => _handleDoubleTap(true),
//                                 child: Container(color: Colors.transparent),
//                               ),
//                             ),
//                             AspectRatio(
//                               aspectRatio: 16 / 9,
//                               child: FittedBox(
//                                 fit: BoxFit.contain,
//                                 child: SizedBox(
//                                   width: videoWidth,
//                                   height: videoHeight,
//                                   child: player,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 onDoubleTap: () => _handleDoubleTap(false),
//                                 child: Container(color: Colors.transparent),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }



import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt_flutter;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/movie.model.dart';
import '../providers/auth.provider.dart';
import '../providers/movie.provider.dart';

class PlayMovieScreen extends StatefulWidget {
  final String movieId;

  const PlayMovieScreen({super.key, required this.movieId});

  @override
  State<PlayMovieScreen> createState() => _PlayMovieScreenState();
}

class _PlayMovieScreenState extends State<PlayMovieScreen> {
  MovieModel? movie;
  bool isLoading = true;
  String? errorMessage;

  yt_flutter.YoutubePlayerController? _mobileController;
  YoutubePlayerController? _webController;

  bool _isFullScreen = false;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.token == null) {
        await authProvider.logout();
        if (mounted) context.go('/login');
        return;
      }

      final fetchedMovie = await movieProvider.fetchMovieById(
        widget.movieId,
        token: authProvider.token,
      );

      if (fetchedMovie.videoUrl.isEmpty) {
        throw Exception('Không tìm thấy URL video YouTube');
      }

      String? videoId = yt_flutter.YoutubePlayer.convertUrlToId(fetchedMovie.videoUrl);

      if (videoId == null) {
        videoId = fetchedMovie.videoUrl;
      }

      if (!RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoId)) {
        throw Exception('ID video YouTube không hợp lệ');
      }

      if (kIsWeb) {
        _webController = YoutubePlayerController(
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            enableCaption: true,
            showVideoAnnotations: false,
          ),
        );
        _webController!.loadVideoById(videoId: videoId);
      } else {
        _mobileController = yt_flutter.YoutubePlayerController(
          initialVideoId: videoId,
          flags: const yt_flutter.YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            loop: false,
            forceHD: false,
            hideControls: false,
            disableDragSeek: false,
          ),
        );
      }

      setState(() {
        movie = fetchedMovie;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi tải video';
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (e.toString().contains('Token không hợp lệ')) {
        await authProvider.logout();
        if (mounted) context.go('/login');
      } else if (e.toString().contains('Không tìm thấy phim')) {
        setState(() => errorMessage = 'Phim không tồn tại');
      } else if (e.toString().contains('URL video') || e.toString().contains('ID video')) {
        setState(() => errorMessage = 'Video không hợp lệ');
      }
    }
  }

  void _handleDoubleTap(bool isLeftSide) {
    if (_mobileController == null) return;
    final currentPosition = _mobileController!.value.position;
    final newPosition = isLeftSide
        ? currentPosition - const Duration(seconds: 10)
        : currentPosition + const Duration(seconds: 10);
    _mobileController!.seekTo(newPosition);
  }

  @override
  void dispose() {
    _mobileController?.dispose();
    _webController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar && !isLandscape
          ? AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          movie?.title ?? 'Phát phim',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Quay lại trang chủ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      )
          : kIsWeb
          ? Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _webController!,
            aspectRatio: 16 / 9,
          ),
        ),
      )
          : yt_flutter.YoutubePlayerBuilder(
        player: yt_flutter.YoutubePlayer(
          controller: _mobileController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const yt_flutter.ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.white,
          ),
          onReady: () {
            _mobileController?.addListener(() {});
          },
          onEnded: (metaData) {
            context.pushReplacement('/movie-detail/${widget.movieId}');
          },
        ),
        onEnterFullScreen: () {
          setState(() {
            _isFullScreen = true;
            _showAppBar = false;
          });
        },
        onExitFullScreen: () {
          setState(() {
            _isFullScreen = false;
            _showAppBar = true;
          });
        },
        builder: (context, player) {
          return GestureDetector(
            onDoubleTap: () {
              setState(() => _showAppBar = !_showAppBar);
            },
            child: Container(
              width: double.infinity,
              height: isLandscape ? screenHeight : screenWidth * 9 / 16,
              color: Colors.black,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ),
          );
        },
      ),
    );
  }
}
