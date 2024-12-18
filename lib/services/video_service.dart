import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/video_model.dart';

class VideoService {
  final String baseUrl = "http://localhost:8000/api/videos";
  final AuthService _authService = AuthService();

  // Fungsi untuk mendapatkan semua video
  Future<List<Video>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> videosJson = data['data']['videos'];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to load videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mencari video berdasarkan query pencarian
  Future<List<Video>> searchVideos(String query) async {
    final url = Uri.parse('$baseUrl?search=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> videosJson = data['data']['videos'];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to search videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Mendapatkan detail video dan video terkait
  Future<Map<String, dynamic>> fetchVideoDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'video': data['data']['video'],
          'relatedVideos': data['data']['relatedVideos'],
        };
      } else {
        throw Exception("Failed to load video details");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan video yang diunggah oleh pengguna
  Future<List<Video>> fetchMyVideos() async {
    try {
      final token =
          await _authService.getToken(); // Get the token from AuthService

      if (token == null) {
        throw Exception("User is not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/my-videos'),
        headers: {
          'Authorization': 'Bearer $token', // Add token to the request header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> videosJson = data['data']['myVideos'];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to load user's videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan video yang disukai oleh pengguna
  Future<List<Video>> fetchLikedVideos() async {
    try {
      final token =
          await _authService.getToken(); // Get the token from AuthService

      if (token == null) {
        throw Exception("User is not authenticated");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/liked-videos'),
        headers: {
          'Authorization': 'Bearer $token', // Add token to the request header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> videosJson = data['data']['likedVideos'];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to load liked videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Tambahkan di VideoService
  Future<void> incrementView(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$videoId/increment-view'),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to increment view");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> incrementLike(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$videoId/increment-like'),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to increment like");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
