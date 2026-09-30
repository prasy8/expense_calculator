import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user_model.dart';

class AuthApiService {
  static const String baseUrl = 'https://prashantech.com/expense-calculator-ver3/api';
  static const String authUrl = '$baseUrl/auth.php';
  
  //Flutter cannot know the response immediately therefore the method returns a Future.
  //Think of 'Future' as "I will give you the result later."
  Future<Map<String,dynamic>> register(
    {required String name, required String email, required String password,}
  ) async{
      final response = await http.post(
                          Uri.parse(authUrl),
                          headers: {
                            'Content-Type':'application/json',
                          },
                          body: jsonEncode({
                            'action': 'register',
                            'name': name,
                            'email': email,
                            'password': password,
                          }),
                       );
      //print('STATUS: ${response.statusCode}');
      //print('BODY: ${response.body}');
      
      return _handleResponse(response);
  }

  Future<Map<String,dynamic>> login(
    {required String email, required String password,}
  ) async{
      final response = await http.post(
                          Uri.parse(authUrl),
                          headers: {
                            'Content-Type':'application/json',
                          },
                          body: jsonEncode({
                            'action': 'login',
                            'email': email,
                            'password': password,
                          }),
                       );
      
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      return _handleResponse(response);
  }

  Future<AuthUserModel> getLoggegInUser(
    String token
  ) async{
      final response = await http.post(
                          Uri.parse(authUrl),
                          headers: {
                            'Content-Type':'application/json',
                            'Authorization':'Bearer $token',
                          },
                          body: jsonEncode({
                            'action': 'me',
                          }),
                       );
      final result = _handleResponse(response);
      if(result['user'] == null){
          throw Exception("User data not found.");
      }

      return AuthUserModel.fromJson(Map<String,dynamic>.from(result['user']),);
  }

  Future<Map<String,dynamic>> logout(
    String token
  ) async{
      final response = await http.post(
                          Uri.parse(authUrl),
                          headers: {
                            'Content-Type':'application/json',
                            'Authorization':'Bearer $token',
                          },
                          body: jsonEncode({
                            'action': 'logout',
                          }),
                       );
      return _handleResponse(response);
      
  }

  Map<String,dynamic> _handleResponse(http.Response response){
      print('Response status: ${response.statusCode}');
      print('Response body: "${response.body}"');

      if (response.body.trim().isEmpty) {
        throw Exception('API returned an empty response. HTTP status: ${response.statusCode}',);
      }

      try {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception('API response is not a JSON object');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return data;
        }

        throw Exception(
          data['message']?.toString() ?? 'Request failed',
        );
      } on FormatException {
        throw Exception('API returned invalid JSON:\n${response.body}',);
      }
      /*
      final decoded = jsonDecode(response.body);
      
      if(response.statusCode<200 || response.statusCode>=300){
          throw Exception(decoded['message']?.toString() ?? 'Something went wrong.',);
      }

      if(decoded['success'] != true){
          throw Exception(decoded['message']?.toString() ?? 'Request Failed.',);
      }

      return Map<String,dynamic>.from(decoded);
      */
  }
}