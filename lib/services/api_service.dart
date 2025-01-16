import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/registration_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<void> submitRegistration(RegistrationModel registration) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/registration'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(registration.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit registration: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
