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

  void _likeVideo() async {
    bool loggedIn = await _authService.isLoggedIn();
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
      // Call the API to like the video
      await _videoService.incrementLike(widget.videoId);
      setState(() {}); // Update UI after liking the video
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
            List likes = video['likes'];

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
                      const SizedBox(height: 8),
                      Text(video['description']),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${likes.length} likes'),
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: _likeVideo, // Call likeVideo function
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Related Videos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(
                  relatedVideos.length,
                  (index) {
                    final related = relatedVideos[index];
                    return ListTile(
                      title: Text(related['title']),
                      subtitle: Text('${related['views']} views'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoDetailPage(
                                videoId: related['id'].toString()),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
