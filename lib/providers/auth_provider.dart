import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier{
    //AuthApiService -> variable/object type,  _apiService->variable name, 
    //_ (underscore)=> variable is intended for internal/private use, AuthApiService()-> create object
    final AuthApiService _apiService = AuthApiService();
    
    AuthUserModel? _user;
    String? _token;
    bool _isLoading = false;
    String? _errorMessage;
    //we don't normally want other parts of your application directly changing _user.
    //so creating a getter named user
    AuthUserModel? get user=>_user;
    String? get token=>_token;
    bool get isLoading=>_isLoading;
    String? get errorMessage=>_errorMessage;

    bool get isLoggedIn{
          //!=> _token is definitely not null
          return _token!=null && _token!.isNotEmpty && _user != null;
    }

    Future<bool> checkLogin() async{
        _setLoading(true);
        _errorMessage = null;

        try{
            final prefs = await SharedPreferences.getInstance();
            final savedToken = prefs.getString('expense_token');

            if(savedToken == null || savedToken.isEmpty){
                _setLoading(false);
                return false;
            }

            final loggedInUser = await _apiService.getLoggegInUser(savedToken);
            _token = savedToken;
            _user  = loggedInUser;
            _setLoading(false);
            return true;
        }
        catch(error){
            await _clearLoginData();
            _errorMessage = error.toString();
            _setLoading(false);
            return false;
        }
    }

    Future<bool> login({required String email, required String password,}) async{
        _setLoading(true);
        _errorMessage = null;

        try{
            final result = await _apiService.login(email:email, password: password,);
            
            final token  = result['token']?.toString();
            if (token == null || token.isEmpty) {
              throw Exception('Login token was not received.');
            }

            final userJson = result['user'];
            if (userJson == null) {
              throw Exception('User data was not received.');
            }

            final loggedInUser = AuthUserModel.fromJson(Map<String,dynamic>.from(userJson));

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('expense_token', token);
            await prefs.setString('expense_user_id', loggedInUser.id.toString(),);
            await prefs.setString('expense_user_name', loggedInUser.name.toString(),);
            await prefs.setString('expense_user_email', loggedInUser.email.toString(),);
            
            _token = token;
            _user  = loggedInUser;            

            _setLoading(false);
            return true;
        }
        catch(error){
            _errorMessage = error.toString();
            _setLoading(false);
            return false;
        }
    }

    Future<bool> register({required String name, required String email, required String password,}) async{
        _setLoading(true);
        _errorMessage = null;

        try{
            await _apiService.register(name:name, email:email, password: password,);
            _setLoading(false);
            return true;
        }
        catch(error){
            _errorMessage = error.toString();
            _setLoading(false);
            return false;
        }
    }

    Future<void> logout() async{
        try{
            if(_token != null && _token!.isNotEmpty){
                await _apiService.logout(_token!);    
            }
        }
        catch(error){
            debugPrint('Logout API error: $error');
        }

        await _clearLoginData();
         _token        = null;
         _user         = null;
         _errorMessage = null;
        //a foundational tool for local state management that signals all listening widgets 
        //to rebuild when an underlying data value or state changes
         notifyListeners();   
    }

    Future<void> _clearLoginData() async{
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('expense_token');
        await prefs.remove('expense_user_id');
        await prefs.remove('expense_user_name');
        await prefs.remove('expense_user_email');
    }

    void clearError(){
        _errorMessage = null;
        notifyListeners();
    }

    void _setLoading(bool value){
        _isLoading = value;
        notifyListeners();
    }
}