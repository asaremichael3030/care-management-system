import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

// Self-service operations for the logged-in user.
class ProfileService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<User> getProfile() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/auth/profile'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return User.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone'] = phone;

    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/auth/profile'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return User.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> changePassword(String current, String next) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/auth/change-password'),
      headers: await _headers(),
      body: jsonEncode({
        'current_password': current,
        'new_password': next,
      }),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  String _error(http.Response r) {
    try {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Request failed.';
    } catch (_) {
      return 'Request failed.';
    }
  }
}