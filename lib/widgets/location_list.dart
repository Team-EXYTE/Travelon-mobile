import 'package:flutter/material.dart';

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  Widget _locationItem(String imagePath, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(radius: 32, backgroundImage: AssetImage(imagePath)),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
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
              _locationItem('assets/location1.jpg', 'Kandy'),
              _locationItem('assets/location3.jpeg', 'Galle'),
              _locationItem('assets/location4.jpeg', 'Anuradhapura'),
              _locationItem('assets/location5.jpg', 'Jaffna'),
              _locationItem('assets/location6.jpg', 'Colombo'),
            ],
          ),
        ),
      ],
    );
  }
}
