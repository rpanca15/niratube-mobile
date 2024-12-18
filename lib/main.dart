import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/public_videos_page.dart';
import 'pages/profile_page.dart';
import 'pages/my_videos_page.dart';
import 'pages/add_video_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthService().initializePrefs();
  } catch (e) {
    print("Error in initializing prefs: $e");
  }

  runApp(VideoStreamingApp());
}

class VideoStreamingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NiraTube | Video Streaming App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MainScreen(),
        '/add-video': (context) => AddVideoPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  // Daftar halaman berdasarkan indeks logis
  final List<Widget> _pages = [
    PublicVideosPage(),
    MyVideosPage(),
    ProfilePage(), // ProfilePage tetap di index 2 (logis)
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek status login
  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _navigateToAddVideo() {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, '/add-video');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to add a video!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex == 2 ? 3 : _currentIndex,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade500,
          onTap: (index) {
            if (index == 3) {
              setState(() {
                _currentIndex = 2;
              });
            } else if (index == 2) {
              _navigateToAddVideo();
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed, // Semua label akan terlihat
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'My Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add Video',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
