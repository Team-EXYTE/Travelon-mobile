import 'package:flutter/material.dart';
import '../screens/location_events_screen.dart';

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  Widget _locationItem(BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationEventsScreen(locationName: label),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Locations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _locationItem(context, 'assets/location1.jpg', 'Kandy'),
              _locationItem(context, 'assets/location3.jpeg', 'Galle'),
              _locationItem(context, 'assets/location4.jpeg', 'Anuradhapura'),
              _locationItem(context, 'assets/location5.jpg', 'Jaffna'),
              _locationItem(context, 'assets/location6.jpg', 'Colombo'),
            ],
          ),
        ),
      ],
    );
  }
}
