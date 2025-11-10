import '../models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RetrieveEventDetails {
  final SupabaseClient database = Supabase.instance.client;

  /// ✅ Retrieve all shops from Supabase
  Future<List<EventModel>> getWeekEvents() async {
    try {
      final response = await database.from('events').select('*');

      // Ensure response is treated as a list
      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) return [];

      // Convert each item to EventModel
      final events = data.map((event) {
        final map = Map<String, dynamic>.from(event);
        return EventModel.fromJson(map);
      }).toList();
      print('📊📊 Fetching events: $events');
      return events;
    } catch (e) {
      print('❌ Error fetching events: $e');
      return [];
    }
  }

  


  /// ✅ Print shops (for debugging)
  Future<void> printShops() async {
    try {
      final events = await getWeekEvents();
      for (final event in events) {
        print('🛒 ${event.title} - ${event.category}');
      }
    } catch (e) {
      print('❌ Error printing shops: $e');
    }
  }
}
