import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'auth_service.dart';

class ReportService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReportSummary> summary() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/reports/summary'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return ReportSummary.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
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