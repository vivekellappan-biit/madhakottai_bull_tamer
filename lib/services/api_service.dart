import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
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

  Future<LoginResponse> login(String username, String password) async {
    try {
      final uri =
          Uri.parse('${AppConstants.baseUrl}/authentication/oauth2/token');

      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'grant_type': 'password',
        'client_id': 'L8VYLzgtWVnmFvtU6b9tuf8t5cmT4XRpYYaZ9yDr',
        'client_secret': 'Z1XzEFxpBKazRtBUipY50C1haQkSZvWgdtoQxh1o',
        'username': username,
        'password': password,
      });

      final streamedResponse =
          await request.send().timeout(const Duration(minutes: 10));

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> submitBullTamer(RegistrationModel tamer) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('${AppConstants.baseUrl}/create');

      print(uri);

      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'model': 'bull_tamers',
        'values': jsonEncode(tamer.toJson()),
      });

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final streamedResponse =
          await request.send().timeout(const Duration(minutes: 10));

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Failed to submit bull tamer data';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print(e);
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to submit bull tamer: $e');
    }
  }

  // Helper method to get token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
