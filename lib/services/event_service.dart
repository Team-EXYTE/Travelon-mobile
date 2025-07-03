import 'package:flutter/material.dart';
import '../data_model/event_model.dart';

class EventService {
  static final List<EventCategory> categories = [
    EventCategory(name: 'Festivals', color: 'deepPurple'),
    EventCategory(name: 'Music', color: 'indigo'),
    EventCategory(name: 'Cultural', color: 'teal'),
    EventCategory(name: 'Wellness', color: 'pinkAccent'),
    EventCategory(name: 'Nature', color: 'green'),
    EventCategory(name: 'Food & Drink', color: 'orange'),
  ];

  static final List<Event> allEvents = [
    // Upcoming Events
    Event(
      id: '1',
      title: 'Batik Workshop',
      imagePath: 'assets/event1.jpeg',
      price: '\$10.99',
      category: 'Cultural',
      description: 'Learn traditional batik making techniques',
      location: 'Colombo',
      date: DateTime.now().add(Duration(days: 5)),
      latitude: 6.9271,
      longitude: 79.8612,
    ),
    Event(
      id: '2',
      title: 'Cooking Class',
      imagePath: 'assets/event2.jpg',
      price: '\$21.99',
      category: 'Food & Drink',
      description: 'Traditional Sri Lankan cooking class',
      location: 'Kandy',
      date: DateTime.now().add(Duration(days: 10)),
      latitude: 7.2906,
      longitude: 80.6337,
    ),
    Event(
      id: '3',
      title: 'Sightseeing',
      imagePath: 'assets/event3.jpg',
      price: '\$14.99',
      category: 'Nature',
      description: 'Explore beautiful natural landscapes',
      location: 'Ella',
      date: DateTime.now().add(Duration(days: 7)),
      latitude: 6.8667,
      longitude: 81.0500,
    ),
    Event(
      id: '4',
      title: 'Dalada Perahera',
      imagePath: 'assets/event5.jpg',
      price: '\$16.99',
      category: 'Festivals',
      description: 'Traditional Buddhist festival procession',
      location: 'Kandy',
      date: DateTime.now().add(Duration(days: 15)),
      latitude: 7.2906,
      longitude: 80.6337,
    ),
    Event(
      id: '5',
      title: 'Kohomba kankariya',
      imagePath: 'assets/event4.webp',
      price: '\$5.99',
      category: 'Cultural',
      description: 'Traditional dance performance',
      location: 'Colombo',
      date: DateTime.now().add(Duration(days: 12)),
      latitude: 6.9271,
      longitude: 79.8612,
    ),
    Event(
      id: '6',
      title: 'Thaipongal',
      imagePath: 'assets/event6.jpg',
      price: '\$8.99',
      category: 'Festivals',
      description: 'Tamil harvest festival celebration',
      location: 'Jaffna',
      date: DateTime.now().add(Duration(days: 20)),
      latitude: 9.6615,
      longitude: 80.0255,
    ),

    // Ended Events
    Event(
      id: '7',
      title: 'Aurudu Festival',
      imagePath: 'assets/ended1.jpg',
      price: 'April 14',
      category: 'Festivals',
      description: 'Sinhala and Tamil New Year celebration',
      location: 'Colombo',
      date: DateTime(2024, 4, 14),
      isEnded: true,
      latitude: 6.9271,
      longitude: 79.8612,
    ),
    Event(
      id: '8',
      title: 'Vesak',
      imagePath: 'assets/ended2.jpg',
      price: 'May 5',
      category: 'Cultural',
      description: 'Buddhist festival of lights',
      location: 'Kandy',
      date: DateTime(2024, 5, 5),
      isEnded: true,
      latitude: 7.2906,
      longitude: 80.6337,
    ),
    Event(
      id: '9',
      title: 'Poson Dansal',
      imagePath: 'assets/ended3.jpg',
      price: 'June 11',
      category: 'Cultural',
      description: 'Free food distribution during Poson festival',
      location: 'Anuradhapura',
      date: DateTime(2024, 6, 11),
      isEnded: true,
      latitude: 8.3114,
      longitude: 80.4037,
    ),
  ];

  static Color getCategoryColor(String colorName) {
    switch (colorName) {
      case 'deepPurple':
        return Colors.deepPurple;
      case 'indigo':
        return Colors.indigo;
      case 'teal':
        return Colors.teal;
      case 'pinkAccent':
        return Colors.pinkAccent;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static List<Event> getUpcomingEvents() {
    return allEvents.where((event) => !event.isEnded).toList();
  }

  static List<Event> getEndedEvents() {
    return allEvents.where((event) => event.isEnded).toList();
  }

  static List<Event> getEventsByCategory(String category) {
    return allEvents.where((event) => event.category == category).toList();
  }

  static List<Event> getUpcomingEventsByCategory(String category) {
    return allEvents
        .where((event) => !event.isEnded && event.category == category)
        .toList();
  }

  static List<Event> getEventsByLocation(String location) {
    return allEvents.where((event) => event.location == location).toList();
  }

  static List<Event> getUpcomingEventsByLocation(String location) {
    return allEvents
        .where((event) => !event.isEnded && event.location == location)
        .toList();
  }
}
