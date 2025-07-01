import 'package:flutter/material.dart';
import '../screens/event_detail_screen.dart';

class EventSection extends StatelessWidget {
  final String title;
  final bool isEnded;

  const EventSection({
    super.key,
    required this.title,
    this.isEnded = false,
  });


Widget _eventCard(BuildContext context, String imagePath, String title, String price) {
  return GestureDetector(
    onTap: () {
      if (!isEnded) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(
              imagePath: imagePath,
              title: title,
              price: price,
            ),
          ),
        );
      }
    },
    child: Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(price, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = isEnded
        ? [
            {'image': 'assets/ended1.jpg', 'title': 'Aurudu Festival', 'price': 'April 14'},
            {'image': 'assets/ended2.jpg', 'title': 'Vesak', 'price': 'May 5'},
            {'image': 'assets/ended3.jpg', 'title': 'Poson Dansal', 'price': 'June 11'},
          ]
        : [
            {'image': 'assets/event1.jpeg', 'title': 'Batik Workshop', 'price': '\$10.99'},
            {'image': 'assets/event2.jpg', 'title': 'Cooking Class', 'price': '\$21.99'},
            {'image': 'assets/event3.avif', 'title': 'Sightseeing', 'price': '\$14.99'},
            {'image': 'assets/event5.jpg', 'title': 'Dalada Perahera', 'price': '\$16.99'},
            {'image': 'assets/event4.webp', 'title': 'Kohomba kankariya', 'price': '\$5.99'},
            {'image': 'assets/event6.jpg', 'title': 'Thaipongal', 'price': '\$8.99'},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: events.map((e) => _eventCard(context, e['image']!, e['title']!, e['price']!)).toList(),
          ),
        ),
      ],
    );
  }
}
