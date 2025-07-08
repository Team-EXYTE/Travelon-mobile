import 'package:flutter/material.dart';
import '../screens/event_detail_screen.dart';
import '../services/firebase_service.dart';
import '../data_model/event_model.dart';

class EventSection extends StatefulWidget {
  final String title;
  final bool isEnded;

  const EventSection({super.key, required this.title, this.isEnded = false});

  @override
  State<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<EventSection> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to fetch events from Firebase
      List<Event> events;
      if (widget.isEnded) {
        debugPrint('Fetching ended events');
        events = await _firebaseService.getEndedEvents();
      } else {
        debugPrint('Fetching upcoming events');
        events = await _firebaseService.getUpcomingEvents();
      }

      debugPrint('Events fetched: ${events.length}');
      if (events.isNotEmpty) {
        debugPrint('First event title: ${events.first.title}');
        debugPrint('First event image: ${events.first.imagePath}');
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
      // Show empty state if Firebase fails
      setState(() {
        _events = [];
        _isLoading = false;
      });
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
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildEventImage(event, 140),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140, // Same width as the image
              child: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(event.price, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Helper method to build an event image
  Widget _buildEventImage(Event event, double size) {
    // Get the primary image path from the event
    String imagePath = event.imagePath;

    // If there are images in the list, prioritize using the first one
    if (event.images.isNotEmpty) {
      imagePath = event.images[0]; // Use first image for home screen
    }

    // Check if the image is a network image or a local asset
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadEvents,
                ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? Center(
                    child: Text(
                      'No ${widget.isEnded ? 'ended' : 'upcoming'} events found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                  : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children:
                        _events
                            .map((event) => _eventCard(context, event))
                            .toList(),
                  ),
        ),
      ],
    );
  }
}
