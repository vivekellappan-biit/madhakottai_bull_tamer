import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bull_tamer.dart';
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

  Future<List<BullTamer>> searchBullTamer(String aadharNumber) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('${AppConstants.baseUrl}/search_read');

      final request = http.MultipartRequest('GET', uri);

      request.fields.addAll({
        'model': 'bull_tamers',
        'domain': '[("aadhar_number","=","$aadharNumber")]',
        'fields':
            '["sequence","aadhar_image","uuid","name","address_line","aadhar_number","create_date","date_of_birth","blood_group","mobile_one","write_uid","profile_image]',
        'limit': '10',
        'offset': '0',
        'order': 'id asc'
      });

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => BullTamer.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('401UNAUTHORIZED');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Search failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('401UNAUTHORIZED');
      }
      throw Exception('Failed to search bull tamer: $e');
    }
  }

  Future<List<BullTamer>> searchBullTamerUUID(String uuid) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('${AppConstants.baseUrl}/search_read');

      print('UUID: $uuid');

      final request = http.MultipartRequest('GET', uri);

      request.fields.addAll({
        'model': 'bull_tamers',
        'domain': '[("uuid","=","$uuid")]',
        'fields':
            '["sequence","uuid","name","address_line","aadhar_number","create_date","date_of_birth","blood_group","mobile_one","write_uid","aadhar_image"]',
        'limit': '10',
        'offset': '0',
        'order': 'id asc'
      });

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => BullTamer.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('401UNAUTHORIZED');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Search failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('401UNAUTHORIZED');
      }
      throw Exception('Failed to search bull tamer: $e');
    }
  }

  Future<void> updatedBullTamer(
      String id, String status, String entryStatus) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      final uri = Uri.parse('${AppConstants.baseUrl}/write');
      print(uri);
      final request = http.MultipartRequest('PUT', uri);

      request.fields.addAll({
        'model': 'bull_tamers',
        'ids': '[$id]',
        'values': '{"$entryStatus": "$status"}',
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
