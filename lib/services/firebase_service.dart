import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data_model/event_model.dart';

class FirebaseService {
  // Category color mapping
  static final Map<String, Color> categoryColors = {
    'music': const Color(0xFFFF5A5F),
    'sports': const Color(0xFF3498DB),
    'food & drink': const Color(0xFFF1C40F),
    'arts & culture': const Color(0xFF9B59B6),
    'outdoor': const Color(0xFF2ECC71),
    'nightlife': const Color(0xFF34495E),
    'technology': const Color(0xFFE74C3C),
    'business': const Color(0xFF1ABC9C),
    'wellness': const Color(0xFFD35400),
    'education': const Color(0xFF27AE60),
    // Legacy mappings for backward compatibility
    'art': const Color(0xFF9B59B6),
    'festival': const Color(0xFFFF5A5F),
    'concert': const Color(0xFFFF5A5F),
    'workshop': const Color(0xFF27AE60),
    'fitness': const Color(0xFFD35400),
    'entertainment': const Color(0xFF34495E),
    'charity': const Color(0xFFE74C3C),
    'community': const Color(0xFF1ABC9C),
    'cultural': const Color(0xFF9B59B6),
    'health': const Color(0xFFD35400),
    'networking': const Color(0xFF1ABC9C),
    'dance': const Color(0xFFFF5A5F),
    'fashion': const Color(0xFF9B59B6),
    'food': const Color(0xFFF1C40F),
  };

  // EventCategory list for map screen
  static List<EventCategory> categories = [
    EventCategory(name: 'Music', color: 'ff5a5f'),
    EventCategory(name: 'Sports', color: '3498db'),
    EventCategory(name: 'Food & Drink', color: 'f1c40f'),
    EventCategory(name: 'Arts & Culture', color: '9b59b6'),
    EventCategory(name: 'Outdoor', color: '2ecc71'),
    EventCategory(name: 'Nightlife', color: '34495e'),
    EventCategory(name: 'Technology', color: 'e74c3c'),
    EventCategory(name: 'Business', color: '1abc9c'),
    EventCategory(name: 'Wellness', color: 'd35400'),
    EventCategory(name: 'Education', color: '27ae60'),
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

    // Try partial match for compound categories (e.g., "Food & Drink" might be passed as just "Food")
    for (final entry in categoryColors.entries) {
      // Check if the category contains the key or vice versa
      if (lowerCategory.contains(entry.key) ||
          entry.key.contains(lowerCategory)) {
        debugPrint(
          'Partial match for category "$category" with key "${entry.key}"',
        );
        return entry.value;
      }
      
      // Special case for compound words
      final categoryWords = lowerCategory.split(RegExp(r'[ &]'));
      final keyWords = entry.key.split(RegExp(r'[ &]'));
      
      // If any words match between the category and the key, it's a match
      for (final word in categoryWords) {
        if (word.length > 2 && keyWords.any((keyWord) => keyWord.contains(word) || word.contains(keyWord))) {
          debugPrint('Word match for "$category" with key "${entry.key}" on word "$word"');
          return entry.value;
        }
      }
    }

    debugPrint('No color found for category: $category, using default');
    return defaultColor;
  }

  // Get color for category from color name string
  static Color getCategoryColor(String colorName) {
    // Try to parse as hex color first (without leading #)
    if (colorName.length == 6) {
      try {
        return Color(int.parse('0xFF$colorName'));
      } catch (e) {
        debugPrint('Failed to parse color: $colorName');
      }
    }
    
    // Fall back to named colors
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
      case 'ff5a5f':
        return const Color(0xFFFF5A5F); // Music
      case '3498db':
        return const Color(0xFF3498DB); // Sports
      case 'f1c40f':
        return const Color(0xFFF1C40F); // Food & Drink
      case '9b59b6':
        return const Color(0xFF9B59B6); // Arts & Culture
      case '2ecc71':
        return const Color(0xFF2ECC71); // Outdoor
      case '34495e':
        return const Color(0xFF34495E); // Nightlife
      case 'e74c3c':
        return const Color(0xFFE74C3C); // Technology
      case '1abc9c':
        return const Color(0xFF1ABC9C); // Business
      case 'd35400':
        return const Color(0xFFD35400); // Wellness
      case '27ae60':
        return const Color(0xFF27AE60); // Education
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
