import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Message>> inbox() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/messages/inbox'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Message.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<Message>> sent() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/messages/sent'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Message.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/messages/unread-count'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return body['count'] as int;
  }

  Future<List<Contact>> contacts() async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/messages/contacts'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Contact.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Message> send({
    required int recipientId,
    String? subject,
    required String body,
  }) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/messages'),
      headers: await _headers(),
      body: jsonEncode({
        'recipient_id': recipientId,
        'subject': subject,
        'body': body,
      }),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Message.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> markRead(int id) async {
    final r = await http.patch(
      Uri.parse('${AuthService.baseUrl}/api/messages/$id/read'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/messages/$id'),
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