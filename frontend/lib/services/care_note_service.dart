import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/care_note.dart';
import 'auth_service.dart';

class CareNoteService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CareNote>> listAll() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/care-notes'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => CareNote.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<List<CareNote>> listByResident(int residentId) async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/care-notes/resident/$residentId'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => CareNote.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<CareNote> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/care-notes'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return CareNote.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/care-notes/$id'),
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