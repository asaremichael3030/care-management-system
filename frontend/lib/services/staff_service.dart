import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff.dart';
import 'auth_service.dart';

class StaffService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Staff>> listAll({String? role, String? status}) async {
    final params = <String, String>{};
    if (role != null) params['role'] = role;
    if (status != null) params['status'] = status;
    final uri = Uri.parse('${AuthService.baseUrl}/api/staff')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => Staff.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<Staff> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/staff'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Staff.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/staff/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/staff/$id'),
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