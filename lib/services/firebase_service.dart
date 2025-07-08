import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data_model/event_model.dart';

class FirebaseService {
  // Category color mapping
  static final Map<String, Color> categoryColors = {
    'music': Colors.purple,
    'sports': Colors.green,
    'food': Colors.orange,
    'art': Colors.blue,
    'festival': Colors.pink,
    'concert': Colors.deepPurple,
    'workshop': Colors.teal,
    'fitness': Colors.lightGreen,
    'education': Colors.indigo,
    'entertainment': Colors.amber,
    'technology': Colors.cyan,
    'charity': Colors.red,
    'community': Colors.brown,
    'business': Colors.blueGrey,
    'cultural': Colors.deepOrange,
    'outdoor': Colors.lightBlue,
    'health': Colors.green,
    'networking': Colors.indigo,
    'dance': Colors.pinkAccent,
    'fashion': Colors.purple,
    // Add more categories and colors as needed
  };

  // EventCategory list for map screen
  static List<EventCategory> categories = [
    EventCategory(name: 'Music', color: 'purple'),
    EventCategory(name: 'Sports', color: 'green'),
    EventCategory(name: 'Food', color: 'orange'),
    EventCategory(name: 'Art', color: 'blue'),
    EventCategory(name: 'Festival', color: 'pink'),
    EventCategory(name: 'Concert', color: 'purple'),
    EventCategory(name: 'Workshop', color: 'teal'),
    EventCategory(name: 'Fitness', color: 'lightGreen'),
    EventCategory(name: 'Education', color: 'indigo'),
    EventCategory(name: 'Entertainment', color: 'amber'),
    // Add more categories as needed
  ];

  // Get color for category by name
  static Color getCategoryColorByName(String category) {
    // Default color if category not found
    const defaultColor = Colors.grey;

    // Case-insensitive match
    final lowerCategory = category.toLowerCase().trim();

    // Direct match first
    if (categoryColors.containsKey(lowerCategory)) {
      return categoryColors[lowerCategory]!;
    }

    // Try partial match
    for (final entry in categoryColors.entries) {
      if (lowerCategory.contains(entry.key) ||
          entry.key.contains(lowerCategory)) {
        debugPrint(
          'Partial match for category "$category" with key "${entry.key}"',
        );
        return entry.value;
      }
    }

    debugPrint('No color found for category: $category, using default');
    return defaultColor;
  }

  // Get color for category from color name string
  static Color getCategoryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'lightgreen':
        return Colors.lightGreen;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'cyan':
        return Colors.cyan;
      case 'red':
        return Colors.red;
      case 'brown':
        return Colors.brown;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'deeporange':
        return Colors.deepOrange;
      case 'lightblue':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all events from Firestore
  Future<List<Event>> getAllEvents() async {
    try {
      debugPrint('Fetching all events from Firestore...');

      // Direct fetch similar to your Next.js example
      final QuerySnapshot eventsSnapshot =
          await _firestore.collection('events').get();
      debugPrint('Got ${eventsSnapshot.docs.length} documents');

      return _convertToEvents(eventsSnapshot);
    } catch (e) {
      debugPrint('Error fetching all events: $e');
      return [];
    }
  }

  // Get upcoming events from Firestore
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final QuerySnapshot eventsSnapshot =
          await _firestore
              .collection('events')
              .where('isEnded', isEqualTo: false)
              .get();

      return _convertToEvents(eventsSnapshot);
    } catch (e) {
      debugPrint('Error fetching upcoming events: $e');
      return [];
    }
  }

  // Get ended events from Firestore
  Future<List<Event>> getEndedEvents() async {
    try {
      final QuerySnapshot eventsSnapshot =
          await _firestore
              .collection('events')
              .where('isEnded', isEqualTo: true)
              .get();

      return _convertToEvents(eventsSnapshot);
    } catch (e) {
      debugPrint('Error fetching ended events: $e');
      return [];
    }
  }

  // Get events by category
  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final QuerySnapshot eventsSnapshot =
          await _firestore
              .collection('events')
              .where('category', isEqualTo: category)
              .get();
      return _convertToEvents(eventsSnapshot);
    } catch (e) {
      debugPrint('Error fetching events by category: $e');
      return [];
    }
  }

  // Get a single event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('events').doc(eventId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Handle date conversion
        DateTime? eventDate;
        if (data['date'] is Timestamp) {
          eventDate = (data['date'] as Timestamp).toDate();
        }

        // Extract images list safely
        List<String> imagesList = [];
        if (data['images'] is List) {
          imagesList = List<String>.from(
            data['images'].map((img) => img.toString()),
          );
        }

        return Event(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          imagePath:
              imagesList.isNotEmpty ? imagesList[0] : 'assets/event1.jpeg',
          images: imagesList,
          price: data['price'] != null ? '\Rs.${data['price']}' : 'Free',
          category: data['category'] ?? 'Uncategorized',
          description: data['description'] ?? 'No description available',
          location: data['location'] ?? 'Unknown location',
          date: eventDate ?? DateTime.now(),
          isEnded: data['isEnded'] ?? false,
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching event by ID: $e');
      return null;
    }
  }

  // Helper method to convert query snapshots to Event objects
  List<Event> _convertToEvents(QuerySnapshot snapshot) {
    debugPrint('Converting ${snapshot.docs.length} documents to events');

    return snapshot.docs.map((doc) {
      // Get document data with ID
      final data = doc.data() as Map<String, dynamic>;
      final id = doc.id;

      debugPrint('Processing event: $id');

      // Handle date conversion (similar to your Next.js example)
      DateTime? eventDate;
      if (data['date'] is Timestamp) {
        eventDate = (data['date'] as Timestamp).toDate();
      }

      // Extract images list safely
      List<String> imagesList = [];
      if (data['images'] is List) {
        imagesList = List<String>.from(
          data['images'].map((img) => img.toString()),
        );
      }

      // Create Event object with data from Firestore
      return Event(
        id: id,
        title: data['title'] ?? 'No Title',
        imagePath: imagesList.isNotEmpty ? imagesList[0] : 'assets/event1.jpeg',
        images: imagesList,
        price: data['price'] != null ? '\Rs.${data['price']}' : 'Free',
        category: data['category'] ?? 'Uncategorized',
        description: data['description'] ?? 'No description available',
        location: data['location'] ?? 'Unknown location',
        date: eventDate ?? DateTime.now(),
        isEnded: data['isEnded'] ?? false,
        latitude: (data['latitude'] ?? 0.0).toDouble(),
        longitude: (data['longitude'] ?? 0.0).toDouble(),
      );
    }).toList();
  }

  // Debug method to examine Firestore collection
  Future<void> debugFirestoreCollection() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('events').get();

      debugPrint('==== FIRESTORE DEBUG ====');
      debugPrint('Total documents: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('Document ID: ${doc.id}');
        debugPrint('Fields: ${data.keys.join(', ')}');

        if (data['title'] != null) {
          debugPrint('Title: ${data['title']}');
        }

        if (data['images'] != null) {
          final images = data['images'] as List;
          debugPrint('Images count: ${images.length}');
          if (images.isNotEmpty) {
            debugPrint('First image: ${images[0]}');
          }
        }

        debugPrint('-------------------');
      }

      debugPrint('==== END DEBUG ====');
    } catch (e) {
      debugPrint('Error in debug method: $e');
    }
  }
}
