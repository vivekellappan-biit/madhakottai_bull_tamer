import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/bull_tamer.dart';
import '../services/api_service.dart';

class BullTamerSearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<BullTamer> searchResults = [];
  String errorMessage = "";
  bool isLoading = false;

  void clearSearchResults() {
    searchResults.clear();
    errorMessage = '';
    notifyListeners();
  }

  Future<void> searchBullTamer(
      String aadharNumber, BuildContext context) async {
    print(aadharNumber);
    try {
      isLoading = true;
      errorMessage = "";
      searchResults = [];
      notifyListeners();

      searchResults = await _apiService.searchBullTamer(aadharNumber);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;

      if (e.toString().contains('401UNAUTHORIZED')) {
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
    }
  }

  Future<void> searchBullTamerByUUID(
      String aadharNumber, BuildContext context) async {
    print(aadharNumber);
    try {
      isLoading = true;
      errorMessage = "";
      searchResults = [];
      notifyListeners();

      searchResults = await _apiService.searchBullTamerUUID(aadharNumber);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;

      if (e.toString().contains('401UNAUTHORIZED')) {
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
    }
  }
}
