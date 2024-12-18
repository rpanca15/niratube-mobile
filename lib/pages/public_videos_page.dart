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
  bool _isLoggedIn = false; // Untuk mengecek apakah user sudah login atau belum

  @override
  void initState() {
    super.initState();
    _videos = VideoService().fetchVideos(); // Menampilkan semua video awalnya
    _checkLoginStatus(); // Memeriksa status login pengguna
  }

  // Fungsi untuk memanggil API berdasarkan pencarian
  void _searchVideos(String query) {
    setState(() {
      if (query.isEmpty) {
        _videos = VideoService()
            .fetchVideos(); // Tampilkan semua video jika pencarian kosong
      } else {
        _videos = VideoService().searchVideos(
            query); // Panggil API untuk mencari video berdasarkan query pencarian
      }
    });
  }

  // Mengecek status login pengguna menggunakan AuthService
  _checkLoginStatus() async {
    bool isLoggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn; // Update status login berdasarkan AuthService
    });
  }

  // Fungsi untuk logout menggunakan AuthService
  _logout() async {
    await AuthService().logout(); // Menggunakan AuthService untuk logout
    setState(() {
      _isLoggedIn = false; // Update status login setelah logout
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Background putih
        elevation: 4, // Memberikan shadow ringan
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white, // Background kolom pencarian
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search videos...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (query) {
                    _searchVideos(
                        query); // Panggil fungsi pencarian saat mengetik
                  },
                ),
              ),
            ),
            // Jika sudah login, tampilkan icon user, jika belum tampilkan tombol login dan register
            _isLoggedIn
                ? IconButton(
                    icon: Icon(Icons.account_circle, color: Colors.white),
                    tooltip: "Profile",
                    onPressed: () {
                      // Bisa diarahkan ke halaman profil jika diperlukan
                    },
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.login, color: Colors.white),
                        tooltip: "Login",
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.app_registration, color: Colors.white),
                        tooltip: "Register",
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
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text(video.title),
                  subtitle: Text(video.description),
                  trailing: Text('${video.likes} likes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailPage(
                          videoId: video.id.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
