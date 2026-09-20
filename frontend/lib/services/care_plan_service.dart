import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/care_plan.dart';
import 'auth_service.dart';

// Talks to /api/care-plans.
class CarePlanService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CarePlan>> listCarePlans() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/care-plans'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw Exception(_error(response));
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => CarePlan.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarePlan>> listByResident(int residentId) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/care-plans/resident/$residentId'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw Exception(_error(response));
    final List data = jsonDecode(response.body) as List;
    return data
        .map((item) => CarePlan.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CarePlan> createCarePlan(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/care-plans'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) throw Exception(_error(response));
    return CarePlan.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CarePlan> updateCarePlan(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/care-plans/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) throw Exception(_error(response));
    return CarePlan.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteCarePlan(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/care-plans/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw Exception(_error(response));
  }

  String _error(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Request failed.';
    } catch (_) {
      return 'Request failed.';
    }
  }
}