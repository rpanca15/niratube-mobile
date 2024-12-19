import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_service.dart';
import '../services/auth_service.dart';

class VideoDetailPage extends StatefulWidget {
  final String videoId;

  const VideoDetailPage({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  VideoPlayerController? _controller;
  late Future<Map<String, dynamic>> _videoData;
  final VideoService _videoService = VideoService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _videoData = _videoService.fetchVideoDetail(widget.videoId);

    // Initialize video player once data is fetched
    _videoData.then((data) {
      final video = data['video'];
      final videoUrl = 'http://localhost:8000/storage/videos/${video['video']}';

      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        }).catchError((error) {
          print("Error loading video: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading video: $error')),
            );
          }
        });
    });
  }

  // Play/Pause video
  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  // Skip forward
  void _skipForward() {
    final currentPosition = _controller!.value.position;
    final newPosition =
        currentPosition + Duration(seconds: 10); // Skip 10 seconds forward
    _controller!.seekTo(newPosition);
  }

  // Skip backward
  void _skipBackward() {
    final currentPosition = _controller!.value.position;
    final newPosition =
        currentPosition - Duration(seconds: 10); // Skip 10 seconds backward
    if (newPosition >= Duration.zero) {
      _controller!.seekTo(newPosition);
    }
  }

  // Like/unlike video
  void _likeVideo() async {
    bool loggedIn = await _authService.isAuthenticated();
    if (!loggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Required'),
          content: Text('You must be logged in to like this video.'),
          actions: <Widget>[
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      );
    } else {
      try {
        // Call the API to increment like
        await _videoService.incrementLike(widget.videoId);
        setState(() {}); // Refresh the page to reflect the change
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error liking the video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Detail"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _videoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No video data available.'));
          } else {
            final video = snapshot.data!['video'];
            final relatedVideos = snapshot.data!['relatedVideos'];

            return ListView(
              children: [
                _controller != null && _controller!.value.isInitialized
                    ? Column(
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.black,
                            ),
                          ),
                          // Controls for Play/Pause, Skip, etc.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.replay_10),
                                onPressed: _skipBackward,
                              ),
                              IconButton(
                                icon: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                              IconButton(
                                icon: Icon(Icons.forward_10),
                                onPressed: _skipForward,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title'],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(video['description']),
                      const SizedBox(height: 10),
                      Text("Likes: ${video['likes_count'] ?? 0}"),
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: _likeVideo, // Call the like/unlike method
                      ),
                      const SizedBox(height: 20),
                      Text('Related Videos', style: TextStyle(fontSize: 18)),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: relatedVideos.length,
                        itemBuilder: (context, index) {
                          final relatedVideo = relatedVideos[index];
                          return ListTile(
                            title: Text(relatedVideo['title']),
                            onTap: () {
                              // Navigate to the selected related video detail page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoDetailPage(
                                    videoId: relatedVideo['id'].toString(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
