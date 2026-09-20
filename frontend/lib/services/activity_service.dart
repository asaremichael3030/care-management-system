import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import 'auth_service.dart';

class ActivityService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Activity>> listAll({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    final uri = Uri.parse('${AuthService.baseUrl}/api/activities')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Activity.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Activity> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/activities'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Activity.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/activities/$id'),
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