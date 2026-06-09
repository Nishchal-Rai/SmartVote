import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Call on app start to restore session
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (token != null && userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final res = await ApiService.login(email, password);
      await _saveSession(res['data']);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change return type from bool to String?
  Future<String?> register(String fullName, String email, String password) async {
    _setLoading(true);
    try {
      final res = await ApiService.register(fullName, email, password);
      await _saveSession(res['data']);
      return res['data']['email'] as String?; // ← return email on success
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null; // ← null means failure
    } finally {
      _setLoading(false);
    }
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Register response only has voterId + email — token comes after OTP
    if (data['token'] != null) {
      await prefs.setString('auth_token', data['token']);
    }
    if (data['user'] != null) {
      await prefs.setString('user_data', jsonEncode(data['user']));
      _user = UserModel.fromJson(data['user']);
    }

    // Save voterId and email so OTP screen can use them
    if (data['voterId'] != null) {
      await prefs.setString('voter_id', data['voterId'].toString());
    }
    if (data['email'] != null) {
      await prefs.setString('pending_email', data['email']);
    }

    _error = null;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
