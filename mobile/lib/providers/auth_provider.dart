import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(String? initialToken) {
    if (initialToken != null) {
      _token = initialToken;
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userDataKey);
    
    if (userJson != null) {
      _user = UserModel.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);
        await prefs.setString(AppConstants.userDataKey, json.encode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Tizimga kirishda xatolik';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tarmoq xatosi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
          'full_name': fullName,
          'role': role,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        _token = data['data']['token'];
        _user = UserModel.fromJson(data['data']['user']);

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);
        await prefs.setString(AppConstants.userDataKey, json.encode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Ro\'yxatdan o\'tishda xatolik';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tarmoq xatosi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userDataKey);

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
