import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final now = DateTime.now();
      
      final response = await _supabase
          .from('events')
          .select('*')
          .gte('schedule_day', now.toIso8601String())
          .order('schedule_day', ascending: true);

      setState(() {
        _events = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _getEventColor(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return Colors.orange;
      case 'tech':
        return Colors.blue;
      case 'entrepreneurship':
        return Colors.purple;
      case 'carrer':
        return Colors.green;
      case 'road trip':
        return Colors.red;
      case 'academic':
        return Colors.indigo;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getEventIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return Icons.build;
      case 'tech':
        return Icons.school;
      case 'carrer':
        return Icons.business_center;
      case 'entrepreneurship':
        return Icons.people;
      case 'road trip':
        return Icons.sports_soccer;
      case 'academic':
        return Icons.menu_book;
      default:
        return Icons.event;
    }
  }

  String _formatEventDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays == 0) {
        return 'Today, ${_formatTime(date)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow, ${_formatTime(date)}';
      } else if (difference.inDays <= 7) {
        return '${DateFormat('EEEE').format(date)}, ${_formatTime(date)}';
      } else {
        return DateFormat('MMM d, yyyy • hh:mm a').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String _getDaysRemaining(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return '1 day';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''}';
      } else {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''}';
      }
    } catch (e) {
      return 'Soon';
    }
  }

  bool _isEventSoon(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);
      return difference.inDays <= 7;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.blue[700]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            'Events',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // This will be masked by ShaderMask
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: _isLoading ? null : _fetchEvents,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[200]!,
                      Colors.purple[200]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_events.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      backgroundColor: Theme.of(context).colorScheme.surface,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title']?.toString() ?? 'Untitled Event';
    final description = event['description']?.toString() ?? '';
    final eventDate = event['schedule_day']?.toString() ?? '';
    final location = event['location']?.toString() ?? '';
    final category = event['category']?.toString() ?? 'General';
    final organizer = event['organizer']?.toString() ?? 'Unknown Organizer';
    final maxParticipants = event['max_participants'];
    final currentParticipants = event['registries'] ?? 0;

    final eventColor = _getEventColor(category);
    final eventIcon = _getEventIcon(category);
    final isSoon = _isEventSoon(eventDate);
    final daysRemaining = _getDaysRemaining(eventDate);
    final isFull = maxParticipants != null && currentParticipants >= maxParticipants;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  eventColor.withOpacity(0.8),
                  eventColor,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(eventIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      daysRemaining,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Event Details
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  text: _formatEventDate(eventDate),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.location_on,
                  text: location,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.person,
                  text: organizer,
                ),

                // Participants Info
                if (maxParticipants != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participants',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: maxParticipants > 0 ? currentParticipants / maxParticipants : 0,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFull ? Colors.red : eventColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentParticipants/${maxParticipants} registered',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FULL',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                // Action Buttons
                Align(
                  alignment: Alignment.center,
                  child:ElevatedButton(
                    onPressed: isFull ? null : () {
                      _registerForEvent(event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: eventColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isFull ? 'Full' : 'Register'),
                  ),
                ),

                
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 8),
              ),
              Container(
                width: 100,
                height: 16,
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 12),
              ),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 8),
              ),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.grey[200],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load events',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming events',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _registerForEvent(Map<String, dynamic> event) {
    // Implement event registration logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registered for ${event['title']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}