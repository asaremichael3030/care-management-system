import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';
import 'auth_service.dart';

class IncidentService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Incident>> listAll({String? status, int? residentId}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (residentId != null) params['residentId'] = '$residentId';
    final uri = Uri.parse('${AuthService.baseUrl}/api/incidents')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Incident.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Incident> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/incidents'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Incident.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Incident> update(int id, Map<String, dynamic> payload) async {
    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/incidents/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return Incident.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/incidents/$id'),
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