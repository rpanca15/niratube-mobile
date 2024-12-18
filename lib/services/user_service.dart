import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart'; // Import AuthService

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Mendapatkan token dari SharedPreferences melalui AuthService
  Future<String?> _getToken() async {
    return await AuthService().getToken();
  }

  // Mengambil profil pengguna berdasarkan token login
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/user/profile', // Pastikan endpoint ini sesuai dengan API kamu
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to load user profile');
    }
  }

  // Mengambil daftar pengguna
  Future<Map<String, dynamic>> getUsers() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/users',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users');
    }
  }

  // Mengambil data pengguna berdasarkan ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/users/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to load user');
    }
  }

  // Membuat pengguna baru
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final token = await _getToken();
    try {
      final response = await _dio.post(
        '/users',
        data: userData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user');
    }
  }

  // Mengupdate data pengguna
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    final token = await _getToken();
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: userData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  // Menghapus pengguna
  Future<void> deleteUser(String userId) async {
    final token = await _getToken();
    try {
      final response = await _dio.delete(
        '/users/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user');
    }
  }
}
