import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madhakottai_bull_tamer/screens/login_screen.dart';
import 'package:madhakottai_bull_tamer/screens/registration_screen.dart';

class SplashProvider extends ChangeNotifier {
  bool isLoggedIn = false;

  SplashProvider() {
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
    isLoggedIn = status;
    notifyListeners();
  }

  void initializeSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }
}
