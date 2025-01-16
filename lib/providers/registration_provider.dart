import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/registration_model.dart';

class RegistrationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitRegistration(RegistrationModel registration) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.submitRegistration(registration);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
