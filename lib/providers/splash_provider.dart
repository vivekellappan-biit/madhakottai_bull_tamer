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

  Future<void> setLogoString(
      String logo, String name, String street, String street2) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logo', logo);
    await prefs.setString('name', name);
    await prefs.setString('street', street);
    await prefs.setString('street2', street2);
    notifyListeners();
  }

  Future<Map<String, String>> getLogoDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'logo': prefs.getString('logo') ?? '',
      'name': prefs.getString('name') ?? '',
      'street': prefs.getString('street') ?? '',
      'street2': prefs.getString('street2') ?? '',
    };
  }

  void initializeSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    if (isLoggedIn) {
      context.go(Routes.loading);
    } else {
      context.go(Routes.login);
    }
  }
}
