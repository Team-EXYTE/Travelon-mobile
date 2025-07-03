import 'package:flutter/material.dart';
import '../screens/event_detail_screen.dart';
import '../services/event_service.dart';
import '../data_model/event_model.dart';

class EventSection extends StatelessWidget {
  final String title;
  final bool isEnded;

  const EventSection({super.key, required this.title, this.isEnded = false});

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
              child: Image.asset(
                event.imagePath,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(event.price, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Event> events =
        isEnded
            ? EventService.getEndedEvents()
            : EventService.getUpcomingEvents();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children:
                events.map((event) => _eventCard(context, event)).toList(),
          ),
        ),
      ],
    );
  }
}
