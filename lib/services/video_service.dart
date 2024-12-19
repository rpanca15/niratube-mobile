import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../models/video_model.dart';
import '../models/category_model.dart';

class VideoService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    headers: {'Content-Type': 'application/json'},
  ));

  final AuthService _authService = AuthService();

  // Fungsi untuk mendapatkan kategori
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = response.data['data'];
        return categoriesJson
            .map((category) => Category.fromJson(category))
            .toList();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> addVideo({
    required String base64Video,
    required String title,
    required String description,
    required String categoryId,
    required String privacy,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final formData = {
        'video': base64Video,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'privacy': privacy,
      };

      final response = await _dio.post(
        '/videos',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add video");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan semua video dengan pencarian
  Future<List<Video>> fetchVideos({String query = ''}) async {
    try {
      final response =
          await _dio.get('/videos', queryParameters: {'search': query});

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['data']['videos'];
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
    return await fetchVideos(
        query: query); // Reuse the fetchVideos function for search
  }

  // Mendapatkan detail video dan video terkait
  Future<Map<String, dynamic>> fetchVideoDetail(String id) async {
    try {
      final response = await _dio.get('/videos/$id/related');

      if (response.statusCode == 200) {
        return {
          'video': response.data['data']['video'],
          'relatedVideos': response.data['data']['relatedVideos'],
          'is_liked': response.data['data']['is_liked'],
          'likes_count': response.data['data']['likes_count'],
        };
      } else {
        throw Exception("Failed to load video details");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan video yang diunggah oleh pengguna dengan pencarian
  Future<List<Video>> fetchMyVideos({String query = ''}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.get(
        '/my-videos',
        queryParameters: {'search': query}, // Menambahkan parameter pencarian
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson =
            response.data['data']['myVideos'] ?? [];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to load user's videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan video yang disukai oleh pengguna dengan pencarian
  Future<List<Video>> fetchLikedVideos({String query = ''}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.get(
        '/liked-videos',
        queryParameters: {'search': query},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson =
            response.data['data']['likedVideos'] ?? [];
        return videosJson.map((video) => Video.fromJson(video)).toList();
      } else {
        throw Exception("Failed to load liked videos");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk menambah view pada video
  Future<void> incrementView(String videoId) async {
    try {
      final response = await _dio.post('/videos/$videoId/increment-view');

      if (response.statusCode != 200) {
        throw Exception("Failed to increment view");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk menambah like pada video
  Future<void> incrementLike(String videoId) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception("User is not authenticated");
      }

      final response = await _dio.post(
        '/videos/$videoId/increment-like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to increment like");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk mendapatkan data video berdasarkan ID untuk halaman edit
  Future<Map<String, dynamic>> fetchVideoForEdit(String videoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.get(
        '/videos/$videoId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Mengembalikan detail video termasuk data kategori
        final videoData = response.data['data']['video'];
        final categoriesData = response.data['data']['categories'];
        return {
          'video': videoData,
          'categories': categoriesData, // Kategori terkait
        };
      } else {
        throw Exception("Failed to load video for edit");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> updateVideo({
    required String videoId,
    required String title,
    required String description,
    required String categoryId,
    required String privacy,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.put(
        '/videos/$videoId',
        data: {
          'title': title,
          'description': description,
          'category_id': categoryId,
          'privacy': privacy,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update video");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk menghapus video
  Future<void> deleteVideo(String videoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.delete(
        '/videos/$videoId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete video");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Fungsi untuk menyukai atau membatalkan like pada video
  Future<void> likeVideo(String videoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception("User is not authenticated");

      final response = await _dio.post(
        '/videos/$videoId/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to like video");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
