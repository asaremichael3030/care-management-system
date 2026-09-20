import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'auth_service.dart';

class NotificationService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> listMine() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/notifications'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => AppNotification.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/notifications/unread-count'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return body['count'] as int;
  }

  Future<void> markRead(int id) async {
    final r = await http.patch(
      Uri.parse('${AuthService.baseUrl}/api/notifications/$id/read'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> markAllRead() async {
    final r = await http.patch(
      Uri.parse('${AuthService.baseUrl}/api/notifications/read-all'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/notifications/$id'),
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