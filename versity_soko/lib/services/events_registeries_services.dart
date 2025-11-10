import 'package:supabase_flutter/supabase_flutter.dart';

class EventRegistriesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Register user for an event if not already registered
  Future<bool> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      // Check if already registered
      final existing = await _supabase
          .from('event_registries')
          .select('id')
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (existing != null) {
        print('⚠️ Already registered for this event.');
        return false;
      }

      // Insert new registration
      await _supabase.from('event_registries').insert({
        'user_id': userId,
        'event_id': eventId,
      });

      print('✅ Registration successful.');
      return true;
    } catch (e) {
      print('❌ Error registering for event: $e');
      return false;
    }
  }

  /// Check if user is registered for a specific event
  Future<bool> isUserRegistered({
    required String userId,
    required String eventId,
  }) async {
    try {
      final result = await _supabase
          .from('event_registries')
          .select('id')
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('❌ Error checking registration: $e');
      return false;
    }
  }

  /// Fetch user event registration history (past + upcoming)
  Future<Map<String, List<Map<String, dynamic>>>> getUserEventHistory(String userId) async {
    try {
      final now = DateTime.now().toUtc();

      // Join with events table to get event details
      final response = await _supabase
          .from('event_registries')
          .select('*, events!inner(id, title, schedule_day, start_time, end_time, location, category, organizer, registries, image_url)')
          .eq('user_id', userId);

      final List<Map<String, dynamic>> pastEvents = [];
      final List<Map<String, dynamic>> upcomingEvents = [];

      for (var item in response) {
        final event = item['events'];
        final scheduleDate = DateTime.parse(event['schedule_day']);

        if (scheduleDate.isBefore(now)) {
          pastEvents.add(event);
        } else {
          upcomingEvents.add(event);
        }
      }

      return {
        'past': pastEvents,
        'upcoming': upcomingEvents,
      };
    } catch (e) {
      print('❌ Error fetching event history: $e');
      return {'past': [], 'upcoming': []};
    }
  }

  /// Get events user should be notified about (within next 24 hours)
  Future<List<Map<String, dynamic>>> getUpcomingNotifications(String userId) async {
    try {
      final now = DateTime.now().toUtc();
      final nextDay = now.add(const Duration(days: 1));

      final response = await _supabase
          .from('event_registries')
          .select('*, events!inner(id, title, schedule_day)')
          .eq('user_id', userId)
          .gte('events.schedule_day', now.toIso8601String())
          .lte('events.schedule_day', nextDay.toIso8601String());

      return response.map<Map<String, dynamic>>((r) => r['events']).toList();
    } catch (e) {
      print('❌ Error fetching upcoming notifications: $e');
      return [];
    }
  }
}
