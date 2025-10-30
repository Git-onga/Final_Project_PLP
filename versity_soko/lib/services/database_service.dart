
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  /// Fetch the logged-in user's profile from the "profiles" table
  Future<Map<String, dynamic>?> loadName() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No user is logged in.');
    }

    try {
      final data = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .single();
       // The new SDK returns a Map<String, dynamic> for .single()

      return  data; // ✅ 'data' is already the user's profile map
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>?> loadBio() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No user is logged in.');
    }

    try {
      final data = await supabase
          .from('profiles')
          .select('bio')
          .eq('id', user.id)
          .single();
       // The new SDK returns a Map<String, dynamic> for .single()

      return  data; // ✅ 'data' is already the user's profile map
    } on PostgrestException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
