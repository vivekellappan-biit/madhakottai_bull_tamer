import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/registration_model.dart';

class RegistrationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String errorMessage = "";
  bool isLoading = false;

  Future<bool> submitBullTamer(RegistrationModel registrationModel) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final tamer = RegistrationModel(
          name: registrationModel.name,
          address_line: registrationModel.address_line,
          district: registrationModel.district,
          bloodGroup: registrationModel.bloodGroup,
          onlineRegNo: '',
          aadharCardNo: registrationModel.aadharCardNo,
          mobileNo: registrationModel.mobileNo,
          aadharImage: registrationModel.aadharImage,
          profileImage: registrationModel.profileImage,
          dateOfBirth: registrationModel.dateOfBirth);
      await _apiService.submitBullTamer(tamer);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }
}
