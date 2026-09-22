import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

// Talks to the backend /api/auth endpoints and stores the session.
class AuthService {
  // Base URL for the API. Override at build time with:
  //   flutter build web --release --dart-define=API_BASE_URL=https://your-backend.com
  // Defaults to localhost for local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Sends credentials to the backend. Returns the User on success.
  // Throws an exception with a readable message on failure.
  Future<User> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'selected_role': selectedRole,
      }),
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Login failed.');
    }

    final String token = body['token'] as String;
    final User user = User.fromJson(body['user'] as Map<String, dynamic>);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  // Reads the saved user, or returns null if nobody is logged in.
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  // Returns the saved token, used by future authenticated requests.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clears the session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}