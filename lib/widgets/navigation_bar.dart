import 'package:flutter/material.dart';
import 'package:travelon_mobile/screens/map_screen.dart';
import '../screens/profile_screen.dart'; // Import your profile screen

class TravelonNavBar extends StatefulWidget {
  const TravelonNavBar({super.key});

  @override
  State<TravelonNavBar> createState() => _TravelonNavBarState();
}

class _TravelonNavBarState extends State<TravelonNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) { // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    }
    // You can add navigation for other tabs here if needed
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 2) {
          // Map icon tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OpenStreetMapScreen()),
          );
        }
        // You can add similar handlers for Home, Cart, Profile if needed
      },
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}