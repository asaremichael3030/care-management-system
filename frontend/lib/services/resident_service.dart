import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resident.dart';
import 'auth_service.dart';

// Talks to /api/residents on the backend.
class ResidentService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Resident>> listResidents() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/residents'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => Resident.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Resident> createResident(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/residents'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception(_extractError(response));
    }
    return Resident.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Resident> updateResident(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/residents/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
    return Resident.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteResident(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/residents/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Request failed.';
    } catch (_) {
      return 'Request failed.';
    }
  }
}