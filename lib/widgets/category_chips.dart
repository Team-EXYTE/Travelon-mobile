import 'package:flutter/material.dart';
import '../screens/category_events_screen.dart';
import '../services/firebase_service.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  Widget _categoryCard(BuildContext context, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryEventsScreen(categoryName: label),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _categoryCard(context, 'Music', const Color.fromARGB(255, 247, 112, 116)),
              _categoryCard(context, 'Sports', const Color.fromARGB(255, 203, 27, 156)),
              _categoryCard(context, 'Food & Drink', const Color(0xFFF1C40F)),
              _categoryCard(context, 'Arts & Culture', const Color.fromARGB(255, 212, 54, 26)),
              _categoryCard(context, 'Outdoor', const Color.fromARGB(255, 52, 254, 126)),
              _categoryCard(context, 'Nightlife', const Color.fromARGB(255, 30, 48, 67)),
              _categoryCard(context, 'Technology', const Color.fromARGB(255, 35, 165, 197)),
              _categoryCard(context, 'Business', const Color.fromARGB(255, 180, 26, 188)),
              _categoryCard(context, 'Wellness', const Color.fromARGB(255, 228, 116, 41)),
              _categoryCard(context, 'Education', const Color.fromARGB(255, 39, 55, 174)),
            ],
          ),
        ),
      ],
    );
  }
}
