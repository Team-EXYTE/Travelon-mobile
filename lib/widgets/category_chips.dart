import 'package:flutter/material.dart';
import '../screens/category_events_screen.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _categoryCard(context, 'Festivals', Colors.deepPurple),
              _categoryCard(context, 'Music', Colors.indigo),
              _categoryCard(context, 'Cultural', Colors.teal),
              _categoryCard(context, 'Wellness', Colors.pinkAccent),
              _categoryCard(context, 'Nature', Colors.green),
              _categoryCard(context, 'Food & Drink', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }
}
