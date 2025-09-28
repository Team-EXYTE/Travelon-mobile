import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Map<String, List<String>> tickets; // userId -> list of ticketIds

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
    this.tickets = const {},
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      imagePath: map['imagePath'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: map['price'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isEnded: map['isEnded'] ?? false,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      tickets:
          map['tickets'] != null
              ? (map['tickets'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, List<String>.from(v)),
              )
              : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imagePath': imagePath,
      'images': images,
      'price': price,
      'category': category,
      'description': description,
      'location': location,
      'address': address,
      'date': date,
      'isEnded': isEnded,
      'latitude': latitude,
      'longitude': longitude,
      'tickets': tickets,
    };
  }
}

class EventCategory {
  final String name;
  final String color;

  EventCategory({required this.name, required this.color});
}
