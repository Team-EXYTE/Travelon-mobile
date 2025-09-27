import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/location_list.dart';
import '../widgets/event_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/navigation_bar.dart';
import '../screens/creator_dashboard.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SearchBarWidget(),
            HeroBanner(),
            LocationList(),
            EventSection(title: 'Upcoming Events', isEnded: false),
            CategoryChips(),
            EventSection(title: 'Recently Ended', isEnded: true),
            SizedBox(height: 70),
          ],
        ),
      ),
      bottomNavigationBar: const TravelonNavBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Image.asset('assets/logo.png', height: 36, fit: BoxFit.contain),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatorDashboard()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}