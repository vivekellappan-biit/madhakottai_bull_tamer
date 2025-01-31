import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madhakottai_bull_tamer/providers/splash_provider.dart';
import 'package:madhakottai_bull_tamer/screens/login_screen.dart';

import 'package:madhakottai_bull_tamer/screens/registration_screen.dart';
import 'package:madhakottai_bull_tamer/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/router.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String errorMessage = "";
  bool isLoading = false;
  String? accessToken;

  bool get isLoggedIn => accessToken != null;

  Future<void> login(
      String username, String password, BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final loginResponse = await _apiService.login(username, password);

      await _saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      accessToken = loginResponse.accessToken;
      errorMessage = "";
      isLoading = false;
      notifyListeners();

      if (context.mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    accessToken = null;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Check for existing login session
  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');

    if (accessToken != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    }
  }

  // Method to get saved token for API calls
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
