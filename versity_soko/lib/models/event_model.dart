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
  final int attendees;
  final String category;

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
    required this.attendees,
    required this.category,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '', // ✅ Supabase uses snake_case
      organizer: json['organizer'] ?? '',
      location: json['location'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      description: json['description'] ?? '',
      isFree: json['is_free'] ?? false,
      ticketLink: json['ticket_link'],
      attendees: json['attendees'] ?? 0,
      category: json['categories'] ?? '',
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
      'attendees': attendees,
      'categories': category,
    };
  }
}
