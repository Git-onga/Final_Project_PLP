// auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  Stream<User?> get authStateChanges => supabase.auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      // Safely check if there's an error
      if (response.user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Signup failed: Unknown error"),
            ),
          );
        }
        return; // Stop execution here
      }

      // If user created successfully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Signup successful! Check your email for confirmation."),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${e.message}")),
        );
      }
    } catch (e) {
      // Catch all other exceptions (e.g., null check)
      debugPrint("Unexpected error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Unexpected error: $e")),
        );
      }
    }
  }

  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.session != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Login successful!")),
          );
        }
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${e.message}")),
        );
      }
      rethrow;
    }
  }

  Future<void> signOut({required BuildContext context}) async {
    try {
      await supabase.auth.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Signed out successfully!")),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${e.message}")),
        );
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Password reset email sent!"),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${e.message}")),
        );
      }
      rethrow;
    }
  }

  // Additional methods you might need
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    // Implement updating user profile in your Supabase profiles table
    await supabase
        .from('profiles')
        .upsert(profileData)
        .select();
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}