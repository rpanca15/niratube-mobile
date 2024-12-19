import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Fungsi untuk login dan mendapatkan token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Menyimpan token yang diterima ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response.data['data']);

        return {'token': response.data['data']}; // Mengembalikan token
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
    try {
      print('Attempting registration with email: $email'); // Debug log

      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      // Menangani respons jika berhasil
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Mengembalikan data user tanpa menyimpan token
        return {'user': response.data['data']};
      } else {
        throw Exception(
            'Registration failed: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Registration Error: $e'); // Debug log
      throw Exception('Registration failed: $e');
    }
  }

  // Fungsi untuk mendapatkan token yang disimpan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('access_token'); // Mengambil token dari SharedPreferences
  }

  // Fungsi untuk logout dan menghapus token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('access_token'); // Menghapus token dari SharedPreferences
  }

  // Fungsi untuk memeriksa apakah token masih valid
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}
