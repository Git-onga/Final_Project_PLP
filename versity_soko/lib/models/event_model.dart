class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String organizer;
  final String location;
  final String date;
  final String time;
  final String description;
  final String? ticketLink;
  final bool isFree;
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
    this.ticketLink,
    this.isFree = true,
    this.attendees = 0,
    this.categories = const [],
  });
}

// Enhanced dummy event data
final List<EventModel> dummyEvents = [
  EventModel(
    id: '1',
    title: "KyU Tech Innovators Hackathon",
    imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
    organizer: "Kirinyaga University Tech Club",
    location: "Auditorium Hall A",
    date: "Sat, Nov 16",
    time: "9:00 AM - 6:00 PM",
    description: "Join developers, designers and innovators for a 1-day challenge to solve campus problems using tech. Win amazing prizes and network with industry professionals.",
    ticketLink: "https://eventbrite.com/kyu-hackathon",
    isFree: true,
    attendees: 124,
    categories: ["Technology", "Workshop", "Competition"],
  ),
  EventModel(
    id: '2',
    title: "Mount Kenya Road Trip",
    imageUrl: 'https://images.unsplash.com/photo-1464822759844-d2d1363b8cab?w=400',
    organizer: "Adventure Society",
    location: "Departure: Main Gate",
    date: "Sun, Nov 24",
    time: "6:00 AM - 8:00 PM",
    description: "A thrilling one-day road trip with fellow students to explore the scenic Mount Kenya region. Includes hiking, photography sessions, and team-building activities.",
    isFree: false,
    ticketLink: "https://tickets.kyu-events.com/roadtrip",
    attendees: 67,
    categories: ["Adventure", "Travel", "Social"],
  ),
  EventModel(
    id: '3',
    title: "Career Fair 2024",
    imageUrl: 'https://images.unsplash.com/photo-1551830416-5a0adb7c5c76?w=400',
    organizer: "Career Development Office",
    location: "University Grounds",
    date: "Fri, Nov 29",
    time: "10:00 AM - 4:00 PM",
    description: "Connect with top employers and explore internship opportunities. Bring your CV and be ready for on-spot interviews.",
    isFree: true,
    attendees: 289,
    categories: ["Career", "Networking", "Professional"],
  ),
  EventModel(
    id: '4',
    title: "Cultural Night Festival",
    imageUrl: 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=400',
    organizer: "Student Union",
    location: "Main Campus Field",
    date: "Sat, Dec 7",
    time: "6:00 PM - 11:00 PM",
    description: "Celebrate diversity with food, music, and performances from different cultures. Traditional attire encouraged!",
    isFree: true,
    attendees: 156,
    categories: ["Cultural", "Food", "Entertainment"],
  ),
  EventModel(
    id: '5',
    title: "Startup Pitch Competition",
    imageUrl: 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=400',
    organizer: "Entrepreneurship Club",
    location: "Business Building Room 101",
    date: "Wed, Nov 20",
    time: "2:00 PM - 5:00 PM",
    description: "Pitch your startup idea to a panel of investors. Winner gets seed funding and mentorship.",
    isFree: false,
    ticketLink: "https://tickets.kyu-events.com/startup-pitch",
    attendees: 89,
    categories: ["Business", "Competition", "Entrepreneurship"],
  ),
];