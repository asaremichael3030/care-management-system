import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medication.dart';
import 'auth_service.dart';

class MedicationService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Medication>> listAll({int? residentId}) async {
    final uri = Uri.parse('${AuthService.baseUrl}/api/medications')
        .replace(queryParameters:
            residentId == null ? null : {'residentId': '$residentId'});
    final r = await http.get(uri, headers: await _headers());
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Medication.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<Medication>> listByResident(int residentId) async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/medications/resident/$residentId'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => Medication.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<Medication> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/medications'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return Medication.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Medication> update(int id, Map<String, dynamic> payload) async {
    final r = await http.put(
      Uri.parse('${AuthService.baseUrl}/api/medications/$id'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    return Medication.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final r = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/medications/$id'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
  }

  Future<MedicationRecord> record(
    int medicationId, {
    required String status,
    String? notes,
  }) async {
    final r = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/medications/$medicationId/record'),
      headers: await _headers(),
      body: jsonEncode({'status': status, 'notes': notes}),
    );
    if (r.statusCode != 201) throw Exception(_error(r));
    return MedicationRecord.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
  }

  Future<List<MedicationRecord>> listRecords(int medicationId) async {
    final r = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/medications/$medicationId/records'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) throw Exception(_error(r));
    final List data = jsonDecode(r.body) as List;
    return data
        .map((i) => MedicationRecord.fromJson(i as Map<String, dynamic>))
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