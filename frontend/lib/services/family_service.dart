import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/family_link.dart';
import '../models/resident.dart';
import 'auth_service.dart';

// Talks to /api/family endpoints.
class FamilyService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<FamilyLink>> listLinks() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/family/links'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to load links.');
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => FamilyLink.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createLink({
    required int userId,
    required int residentId,
    String? relationship,
    bool isPrimary = false,
  }) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/family/links'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'resident_id': residentId,
        'relationship': relationship,
        'is_primary': isPrimary,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFrom(response));
    }
  }

  Future<void> deleteLink(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/family/links/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to remove link.');
  }

  // Returns the resident(s) linked to the logged-in family member.
  Future<List<Resident>> myRelative() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/family/my-relative'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFrom(response));
    }
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => Resident.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _errorFrom(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Request failed.';
    } catch (_) {
      return 'Request failed.';
    }
  }
}