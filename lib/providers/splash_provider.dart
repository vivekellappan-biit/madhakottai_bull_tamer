import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/screens/login_screen.dart';

class SplashProvider extends ChangeNotifier {
  void initializeSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}
