  import 'package:flutter/material.dart';
  import 'package:onelandscape/features/auth/data/auth_repository.dart';
  import 'package:onelandscape/features/auth/data/models/user_model.dart';

  class AuthProvider extends ChangeNotifier {
    final AuthRepository _authRepository = AuthRepository();

    User? _user;
    bool _isLoading = false;
    String? _errorMessage;
    bool _isCheckingAuth = true;

    User? get user => _user;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    bool get isAuthenticated => _user != null;
    bool get isCheckingAuth => _isCheckingAuth;

    Future<void> checkLoginStatus() async {
      try {
        _user = await _authRepository.getProfile();
      } catch (e) {
        _user = null;
      } finally {
        _isCheckingAuth = false;
        notifyListeners();
      }
    }

    Future<bool> login(String email, String password) async {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      try {
        await _authRepository.login(email: email, password: password);
        _user = await _authRepository.getProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    Future<void> logout() async {
      await _authRepository.logout();
      _user = null;
      notifyListeners();
    }

    Future<bool> register({required String name, required String email, required String password}) async {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      try {
        await _authRepository.register(name: name, email: email, password: password);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
  }