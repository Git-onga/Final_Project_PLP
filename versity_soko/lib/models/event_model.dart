class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String organizer;
  final String location;
  final String scheduleDate;
  final String startTime;
  final String endTime;
  final String description;
  final bool isFree;
  final String? ticketLink;
  final int registries;
  final String category;
  final int maxParticipants;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.organizer,
    required this.location,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.isFree,
    this.ticketLink,
    required this.registries,
    required this.category,
    required this.maxParticipants,

  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Handle flexible date formats safely
    String? rawDate = json['schedule_day']?.toString();
    String parsedDate = '';

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(rawDate).toIso8601String();
      } catch (_) {
        // Try handling other possible date formats from Supabase or custom input
        if (rawDate.contains(' ')) {
          parsedDate = rawDate.split(' ').first; // trims off time
        } else if (rawDate.contains('/')) {
          // handle DD/MM/YYYY or MM/DD/YYYY
          final parts = rawDate.split('/');
          if (parts.length == 3) {
            final day = parts[0].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            final year = parts[2];
            parsedDate = '$year-$month-$day';
          }
        }
      }
    }


    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      imageUrl: json['image_url'] ?? '',
      organizer: json['organizer'] ?? '',
      location: json['location'] ?? '',
      scheduleDate: parsedDate, // ✅ safely parsed
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      description: json['description'] ?? '',
      isFree: json['is_free'] ?? false,
      ticketLink: json['ticket_link'],
      registries: json['registries'] ?? 0,
      category: json['category'] ?? '',
      maxParticipants: json['max_participants'] ?? 0,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl, // ✅ matches Supabase column name
      'organizer': organizer,
      'location': location,
      'schedule_date': scheduleDate,
      'start_time': startTime,
      'end_time': endTime,
      'description': description,
      'is_free': isFree,
      'ticket_link': ticketLink,
      'attendees': registries,
      'categories': category,
      'max_participants': maxParticipants,
    };
  }
}
