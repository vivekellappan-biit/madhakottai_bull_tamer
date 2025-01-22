import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/router.dart';

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
      context.go(Routes.home);
    } else {
      context.go(Routes.login);
    }
  }
}
