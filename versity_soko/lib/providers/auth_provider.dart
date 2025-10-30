// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/profile/profile_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.userMetadata?['name'] as String?;
  String? get userId => _user?.id;

  // Initialize auth state listener
  void initializeAuthListener() {
    if (_isInitialized) return;
    
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// REFRESH USER DATA
  Future<void> refreshUser() async {
    try {
      // Get the current user from Supabase auth
      final currentUser = _authService.currentUser;
      
      // Update the local user state
      _user = currentUser;
      
      // If you're using a profiles table, fetch the latest profile data
      if (currentUser != null) {
        await _refreshUserProfile();
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('User refreshed: ${_user?.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user: $e');
      }
      // Don't throw error here to avoid breaking the UI
    }
  }

  /// REFRESH USER PROFILE DATA from profiles table
  Future<void> _refreshUserProfile() async {
    try {
      final userProfile = await getUserProfile();
      if (userProfile != null) {
        // Update user metadata with profile data
        await _authService.supabase.auth.updateUser(
          UserAttributes(
            data: {
              'name': userProfile['name'],
              'bio': userProfile['bio'],
              // Add other profile fields as needed
            },
          ),
        );
        
        // Refresh the user object to include updated metadata
        _user = _authService.currentUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user profile: $e');
      }
    }
  }

  /// FORCE REFRESH SESSION AND USER DATA
  Future<void> forceRefresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This will refresh the session and get the latest user data
      final response = await supabase.auth.refreshSession();
      
      if (response.session != null) {
        _user = response.session!.user;
      } else {
        _user = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// LOGIN with email and password
  Future<bool> login(String email, String password, {required BuildContext context}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInUser(
        email: email.toLowerCase().trim(),
        password: password,
        context: context,
      );
      
      // Refresh user data after login
      await refreshUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// REGISTER new user with email and password
  Future<bool> register(String name, String email, String password, {required BuildContext context}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpUser(
        name: name,
        email: email.toLowerCase().trim(),
        password: password,
        context: context,
      );

      // Set user metadata after registration
      if (_authService.currentUser != null) {
        await _authService.supabase.auth.updateUser(
          UserAttributes(
            data: {'name': name},
          ),
        );
        
        // Refresh user data
        await refreshUser();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// GET USER PROFILE DATA
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _user?.id;
      if (userId == null) return null;
      
      final supabase = _authService.supabase;
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      return null;
    }
  }

  /// CLEAR ERRORS
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// GET FRIENDLY ERROR MESSAGES
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'Email not confirmed':
          return 'Please confirm your email address before signing in.';
        case 'User already registered':
          return 'An account with this email already exists.';
        case 'Weak password':
          return 'Password is too weak. Please choose a stronger password.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}
