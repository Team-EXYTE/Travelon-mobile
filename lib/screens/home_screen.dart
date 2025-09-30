import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/location_list.dart';
import '../widgets/event_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/navigation_bar.dart';
import '../screens/creator_dashboard.dart';
import 'chatbot_screen.dart';
import 'questionnaire_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchBarWidget(),
                const HeroBanner(),
                const LocationList(),
                const EventSection(title: 'Upcoming Events', isEnded: false),
                const CategoryChips(),
                const EventSection(title: 'Recently Ended', isEnded: true),
                // Personalization Banner (styled)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Remove fixed height, let image and overlay size to content
                        Positioned.fill(
                          child: Image.asset(
                            'assets/personalise.png',
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.35),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 22,
                                    child: Icon(
                                      Icons.stars,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Personalize Your Experience',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Get event suggestions tailored just for you. Answer a few quick questions to unlock your personalized recommendations!',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const QuestionnaireScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Personalize Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: Colors.black,
        tooltip: 'Chat with our Assistant',
        child: const Icon(Icons.support_agent, color: Colors.white, size: 36),
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
