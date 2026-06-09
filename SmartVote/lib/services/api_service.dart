import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.37.8.92:8080/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'fullName': fullName, 'email': email, 'password': password}),
    );
    return _handle(res);
  }

  // static Future<Map<String, dynamic>> verifyOtp(
  //     String email) async {
  //   final res = await http.post(
  //     Uri.parse('$baseUrl/auth/verifyOtp'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email}),
  //   );
  //   return _handle(res);
  // }


  // ── Elections ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getActiveElections() async {
    final res = await http.get(
      Uri.parse('$baseUrl/elections'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getElection(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/elections/$id'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> castVote(
      int electionId, int candidateId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/elections/vote'),
      headers: await _authHeaders(),
      body: jsonEncode(
          {'electionId': electionId, 'candidateId': candidateId}),
    );
    return _handle(res);
  }

  // ── Admin ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAllElections() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/elections'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> createElection(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/elections'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateElectionStatus(
      int id, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/elections/$id/status'),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    return _handle(res);
  }

  // ── Helper ────────────────────────────────────────────────
  static Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(body['message'] ?? 'An error occurred', res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
