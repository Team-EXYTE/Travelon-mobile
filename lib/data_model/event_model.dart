class Event {
  final String id;
  final String title;
  final String imagePath;
  final String price;
  final String category;
  final String description;
  final String location;
  final DateTime date;
  final bool isEnded;
  final double latitude;
  final double longitude;

  Event({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    this.isEnded = false,
    required this.latitude,
    required this.longitude,
  });
}

class EventCategory {
  final String name;
  final String color;

  EventCategory({
    required this.name,
    required this.color,
  });
}
