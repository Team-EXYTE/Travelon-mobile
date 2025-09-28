class Event {
  final String id;
  final String title;
  final String imagePath;
  final List<String> images; // Add images list
  final String price;
  final String category;
  final String description;
  final String location;
  final String address;
  final DateTime date;
  final bool isEnded;
  final double latitude;
  final double longitude;

  Event({
    required this.id,
    required this.title,
    required this.imagePath,
    this.images = const [], // Default to empty list
    required this.price,
    required this.category,
    required this.description,
    required this.location,
    required this.address,
    required this.date,
    this.isEnded = false,
    required this.latitude,
    required this.longitude,
  });
}

class EventCategory {
  final String name;
  final String color;

  EventCategory({required this.name, required this.color});
}
