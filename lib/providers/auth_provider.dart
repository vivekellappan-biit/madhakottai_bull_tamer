import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/screens/registration_screen.dart';

class AuthProvider extends ChangeNotifier {
  String errorMessage = "";

  void login(String username, String password, BuildContext context) {
    // Dummy authentication logic
    if (username == "admin" && password == "password") {
      errorMessage = "";
      notifyListeners();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    } else {
      errorMessage = "Invalid username or password";
      notifyListeners();
    }
  }
}
