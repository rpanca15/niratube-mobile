import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  late SharedPreferences _prefs;

  // Konstruktor private
  AuthService._internal();

  // Inisialisasi SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Memastikan SharedPreferences telah diinisialisasi
  Future<void> _ensureInitialized() async {
    if (!(_prefs != null)) {
      await _initPrefs();
    }
  }

  // Method untuk memulai inisialisasi SharedPreferences (bisa dipanggil di main.dart)
  Future<void> initializePrefs() async {
    await _initPrefs();
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['data'];
        await _prefs.setString('auth_token', token);
        return token;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Register
  Future<String?> register(String name, String email, String password,
      String passwordConfirmation) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 200) {
        final token = response.data['data'];
        await _prefs.setString('auth_token', token);
        return token;
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      String? token = _prefs.getString('auth_token');

      if (token != null) {
        await _dio.post('/logout',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        await _prefs.remove('auth_token');
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // Cek apakah sudah login
  Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    String? token = _prefs.getString('auth_token');
    return token != null;
  }

  // Mendapatkan token yang disimpan
  Future<String?> getToken() async {
    await _ensureInitialized();
    return _prefs.getString('auth_token');
  }
}
