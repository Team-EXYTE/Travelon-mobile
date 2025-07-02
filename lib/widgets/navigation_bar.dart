import 'package:flutter/material.dart';
import 'package:travelon_mobile/screens/map_screen.dart';

class TravelonNavBar extends StatelessWidget {
  const TravelonNavBar({super.key});

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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
