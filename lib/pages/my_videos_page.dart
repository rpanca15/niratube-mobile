import 'package:flutter/material.dart';
import '../services/video_service.dart';  // Adjust the import as needed
import '../models/video_model.dart';      // Adjust the import as needed

class MyVideosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Videos'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'My Videos'),
              Tab(text: 'Liked Videos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyVideosTab(),
            LikedVideosTab(),
          ],
        ),
      ),
    );
  }
}

class MyVideosTab extends StatelessWidget {
  final VideoService _videoService = VideoService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Add Video Logic
          },
          child: Text('Add Video'),
        ),
        Expanded(
          child: FutureBuilder<List<Video>>(
            future: _videoService.fetchMyVideos(),
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
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return ListTile(
                      title: Text(video.title),
                      subtitle: Text(video.description),
                      leading: Icon(Icons.video_collection),
                      onTap: () {
                        // Navigate to video detail page or any other action
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class LikedVideosTab extends StatelessWidget {
  final VideoService _videoService = VideoService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Video>>(
            future: _videoService.fetchLikedVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No liked videos found.'));
              } else {
                final videos = snapshot.data!;
                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return ListTile(
                      title: Text(video.title),
                      subtitle: Text(video.description),
                      leading: Icon(Icons.favorite),
                      onTap: () {
                        // Navigate to video detail page or any other action
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
