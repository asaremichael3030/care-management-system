import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

// Admin-only operations on user accounts.
class AdminUserService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<User>> list({
    String? role,
    String? status,
    String? search,
  }) async {
    final params = <String, String>{};
    if (role != null) params['role'] = role;
    if (status != null) params['status'] = status;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    final uri = Uri.parse('${AuthService.baseUrl}/api/users')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => User.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<void> update(
    int id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (role != null) body['role'] = role;
    if (status != null) body['status'] = status;

    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/users/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> resetPassword(int id, String password) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/users/$id/reset-password'),
      headers: await _headers(),
      body: jsonEncode({'password': password}),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/users/$id'),
      headers: await _headers(),
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