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
              _categoryCard(context, 'Music', const Color(0xFFFF5A5F)),
              _categoryCard(context, 'Sports', const Color(0xFF3498DB)),
              _categoryCard(context, 'Food & Drink', const Color(0xFFF1C40F)),
              _categoryCard(context, 'Arts & Culture', const Color(0xFF9B59B6)),
              _categoryCard(context, 'Outdoor', const Color(0xFF2ECC71)),
              _categoryCard(context, 'Nightlife', const Color(0xFF34495E)),
              _categoryCard(context, 'Technology', const Color(0xFFE74C3C)),
              _categoryCard(context, 'Business', const Color(0xFF1ABC9C)),
              _categoryCard(context, 'Wellness', const Color(0xFFD35400)),
              _categoryCard(context, 'Education', const Color(0xFF27AE60)),
            ],
          ),
        ),
      ],
    );
  }
}
