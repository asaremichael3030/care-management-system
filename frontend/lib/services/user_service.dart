import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

// Reads users from the backend (used for the family-link picker).
class UserService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<User>> listByRole(String role) async {
    final uri = Uri.parse(
      '${AuthService.baseUrl}/api/users?role=${Uri.encodeComponent(role)}',
    );
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw Exception('Failed to load users.');
    }
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}