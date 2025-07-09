import 'package:flutter/material.dart';
import '../data_model/event_model.dart';
import '../screens/event_detail_screen.dart';
import '../services/firebase_service.dart';
import '../widgets/safe_scrollable.dart';

class LocationEventsScreen extends StatefulWidget {
  final String locationName;

  const LocationEventsScreen({super.key, required this.locationName});

  @override
  State<LocationEventsScreen> createState() => _LocationEventsScreenState();
}

class _LocationEventsScreenState extends State<LocationEventsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get all events and filter by location
      final allEvents = await _firebaseService.getAllEvents();
      final locationEvents =
          allEvents
              .where((event) => event.location == widget.locationName)
              .toList();

      setState(() {
        _events = locationEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load events: $e";
        _isLoading = false;
      });
      debugPrint("Error loading location events: $e");
    }
  }

  // Helper method to build an event image
  Widget _buildEventImage(Event event, double width, double height) {
    // Get the primary image path from the event
    String imagePath = event.imagePath;

    // If there are images in the list, prioritize using the first one
    if (event.images.isNotEmpty) {
      imagePath = event.images[0]; // Use first image
    }

    // Check if the image is a network image or a local asset
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _eventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => EventDetailScreen(
                  imagePath: event.imagePath,
                  title: event.title,
                  price: event.price,
                  event: event,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: _buildEventImage(event, 120, 120),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (event.isEnded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ended',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: FirebaseService.getCategoryColorByName(
                                event.category,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: FirebaseService.getCategoryColorByName(
                                  event.category,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.price,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The events are loaded in initState via _loadEvents() method
    // Now we can just split the events based on isEnded flag
    final upcomingEvents = _events.where((e) => !e.isEnded).toList();
    final endedEvents = _events.where((e) => e.isEnded).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Flexible(
          child: Text(
            'Events in ${widget.locationName}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
      body:
          _events.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No events found in ${widget.locationName}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new events',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : SafeScrollable(
                heightFactor: 0.85,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (upcomingEvents.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Upcoming Events',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${upcomingEvents.length}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...upcomingEvents.map(
                          (event) => _eventCard(context, event),
                        ),
                      ],
                      if (endedEvents.isNotEmpty) ...[
                        if (upcomingEvents.isNotEmpty)
                          const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.event_busy,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Past Events',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${endedEvents.length}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...endedEvents.map(
                          (event) => _eventCard(context, event),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
