import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../services/auth_service.dart';
import 'video_detail_page.dart';

class PublicVideosPage extends StatefulWidget {
  @override
  _PublicVideosPageState createState() => _PublicVideosPageState();
}

class _PublicVideosPageState extends State<PublicVideosPage> {
  late Future<List<Video>> _videos;
  TextEditingController _searchController = TextEditingController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _videos = VideoService().fetchVideos();
    _checkLoginStatus();
  }

  void _searchVideos(String query) {
    setState(() {
      if (query.isEmpty) {
        _videos = VideoService().fetchVideos();
      } else {
        _videos = VideoService().searchVideos(query);
      }
    });
  }

  _checkLoginStatus() async {
    bool isLoggedIn = await AuthService().isAuthenticated();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  _logout() async {
    await AuthService().logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search videos...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                              _searchVideos('');
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: _searchVideos,
                ),
              ),
            ),
            _isLoggedIn
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      _logout();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Logout', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.account_circle, color: Colors.blue),
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.login, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.app_registration, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
      body: FutureBuilder<List<Video>>(
        future: _videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found.'));
          } else {
            final videos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoDetailPage(videoId: video.id.toString()),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        // Left side - Thumbnail
                        Container(
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://picsum.photos/200/300'), // Random image URL
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(10)),
                          ),
                        ),
                        // Right side - Video Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  video.description,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${video.likesCount} likes',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
