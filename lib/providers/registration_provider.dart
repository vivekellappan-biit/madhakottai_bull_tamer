import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/registration_model.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegistrationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String errorMessage = "";
  bool isLoading = false;

  Future<bool> submitBullTamer(
      RegistrationModel registrationModel, BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final tamer = RegistrationModel(
          name: registrationModel.name,
          address_line: registrationModel.address_line,
          district: registrationModel.district,
          bloodGroup: registrationModel.bloodGroup,
          onlineRegNo: registrationModel.onlineRegNo,
          aadharCardNo: registrationModel.aadharCardNo,
          mobileNo: registrationModel.mobileNo,
          aadharImage: registrationModel.aadharImage,
          profileImage: registrationModel.profileImage,
          emergencyMobileNo: registrationModel.emergencyMobileNo,
          dateOfBirth: registrationModel.dateOfBirth);

      await _apiService.submitBullTamer(tamer);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;

      if (e.toString().contains('401')) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Session Expired'),
                content:
                    const Text('Your session has expired. Please login again.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      authProvider.logout(context);
                    },
                  ),
                ],
              );
            },
          );
        }

        errorMessage = 'Session expired. Please login again.';
      } else {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> updatedEntryStatus(String id, String status, String entryStatus,
      BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      await _apiService.updatedBullTamer(id, status, entryStatus);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;

      if (e.toString().contains('401')) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Session Expired'),
                content:
                    const Text('Your session has expired. Please login again.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      authProvider.logout(context);
                    },
                  ),
                ],
              );
            },
          );
        }

        errorMessage = 'Session expired. Please login again.';
      } else {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      notifyListeners();
      return false;
    }
  }
}
