class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String organizer;
  final String location;
  final String date;
  final String time;
  final String description;
  final bool isFree;
  final String? ticketLink;
  final int attendees;
  final List<String> categories;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.organizer,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    required this.isFree,
    this.ticketLink,
    required this.attendees,
    required this.categories,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      organizer: map['organizer'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      isFree: map['isFree'] ?? false,
      ticketLink: map['ticketLink'],
      attendees: map['attendees'] ?? 0,
      categories: List<String>.from(map['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'location': location,
      'date': date,
      'time': time,
      'description': description,
      'isFree': isFree,
      'ticketLink': ticketLink,
      'attendees': attendees,
      'categories': categories,
    };
  }
}
