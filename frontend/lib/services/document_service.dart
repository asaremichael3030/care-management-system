import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import 'auth_service.dart';

class DocumentService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ResidentDocument>> listAll({int? residentId}) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/documents')
        .replace(
      queryParameters:
          residentId == null ? null : {'residentId': '$residentId'},
    );
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => ResidentDocument.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<ResidentDocument>> listByResident(int residentId) async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/documents/resident/$residentId'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => ResidentDocument.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<ResidentDocument> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/documents'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return ResidentDocument.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
  }

  Future<ResidentDocument> update(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/documents/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return ResidentDocument.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/documents/$id'),
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