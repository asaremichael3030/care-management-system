import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shift.dart';
import 'auth_service.dart';

class ShiftService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Shift>> listAll({
    int? staffId,
    String? date,
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (staffId != null) params['staffId'] = '$staffId';
    if (date != null) params['date'] = date;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final uri = Uri.parse('${AuthService.baseUrl}/api/shifts')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => Shift.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<List<Shift>> listMine() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/shifts/mine'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => Shift.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<Shift> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/shifts'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Shift.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Shift> update(int id, Map<String, dynamic> payload) async {
    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/shifts/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return Shift.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/shifts/$id'),
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