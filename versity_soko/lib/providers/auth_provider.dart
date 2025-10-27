// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user; // Firebase User
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.login(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// REGISTER / CREATE ACCOUNT
  Future<bool> register(String name, String email, String password, String university) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create Firebase user
      UserCredential userCredential = await _authService.createAccount(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
      );

      // Update username in Firebase
      await _authService.updateUsername(username: name.trim());

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// RESET PASSWORD
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// UPDATE USERNAME
  Future<bool> updateUsername(String username) async {
    try {
      await _authService.updateUsername(username: username);
      _user = _authService.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// UPDATE USERNAME
  Future<bool> updateEmail(String email) async {
    try {
      await _authService.updateEmail(email: email);
      email = email;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// SIGN OUT
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// DELETE ACCOUNT
  Future<bool> deleteAccount(String email, String password) async {
    try {
      await _authService.deleteAccount(email: email, password: password);
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// RESET PASSWORD (WITH CURRENT PASSWORD)
  Future<bool> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      await _authService.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: email,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// CLEAR ERRORS
  void clearError() {
    _error = null;
    notifyListeners();
  }

  
}