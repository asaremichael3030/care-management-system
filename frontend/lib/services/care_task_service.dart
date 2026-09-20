import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/care_task.dart';
import 'auth_service.dart';

class CareTaskService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CareTask>> listAll({String? status}) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/care-tasks').replace(
      queryParameters: status == null ? null : {'status': status},
    );
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => CareTask.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<List<CareTask>> listMine() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/care-tasks/mine'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data.map((i) => CareTask.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<CareTask> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/care-tasks'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return CareTask.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<CareTask> complete(int id, {String? notes}) async {
    final r = await http.patch(
      Uri.parse('${AuthService.baseUrl}/api/care-tasks/$id/complete'),
      headers: await _headers(),
      body: jsonEncode({'notes': notes}),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return CareTask.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/care-tasks/$id'),
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