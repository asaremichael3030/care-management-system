import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audit_log.dart';
import 'auth_service.dart';

class AuditLogService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AuditLog>> list({
    String? action,
    String? entityType,
    int? userId,
    int? limit,
  }) async {
    final params = <String, String>{};
    if (action != null) params['action'] = action;
    if (entityType != null) params['entityType'] = entityType;
    if (userId != null) params['userId'] = '$userId';
    if (limit != null) params['limit'] = '$limit';
    final uri = Uri.parse('${AuthService.baseUrl}/api/audit-logs')
        .replace(queryParameters: params.isEmpty ? null : params);
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => AuditLog.fromJson(i as Map<String, dynamic>))
        .toList();
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