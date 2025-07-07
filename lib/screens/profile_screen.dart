import 'package:flutter/material.dart';
import 'settings_screen.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  // For demonstration, hardcoded username. Replace with your user variable.
  final String userName = 'Saman Perera';
  final String phoneNumber = '+94 77 123 4567';

  @override
  Widget build(BuildContext context) {
    // Get first letter of username, fallback to '?'
    final String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TRAVELON',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                } else if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Add your logout logic here
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: const [
                      Icon(Icons.settings, color: Colors.teal),
                      SizedBox(width: 10),
                      Text('Settings', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.teal),
                      SizedBox(width: 10),
                      Text('Logout', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Fancy Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 86, 199, 240)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.teal,
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          phoneNumber,
                          style: const TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Since 2 January 2025',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Member Gold',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Profile Tiles Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        title: 'History',
                        icon: Icons.history,
                        color: Colors.blue.shade700,
                        details: const [
                          {
                            'icon': Icons.location_on,
                            'title': 'Sigiriya Tour',
                            'subtitle': 'Visited on 12 June 2025'
                          },
                          {
                            'icon': Icons.location_on,
                            'title': 'Ella Hiking Adventure',
                            'subtitle': 'Visited on 7 June 2025'
                          },
                        ],
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        title: 'My Reviews',
                        icon: Icons.star,
                        color: Colors.amber,
                        details: const [
                          {
                            'icon': Icons.star,
                            'title': 'Sigiriya Rock Fortress',
                            'subtitle': '5 stars - Breathtaking view and history!'
                          },
                          {
                            'icon': Icons.star,
                            'title': 'Ella Nine Arch Bridge',
                            'subtitle': '4 stars - Beautiful scenery and train experience.'
                          },
                        ],
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        title: 'My Bookings',
                        icon: Icons.book_online,
                        color: Colors.teal,
                        details: const [
                          {
                            'icon': Icons.book_online,
                            'title': 'Katharagama',
                            'subtitle': 'Booked for 12 July 2025'
                          },
                          {
                            'icon': Icons.book_online,
                            'title': 'Hikkaduwa',
                            'subtitle': 'Booked for 2 August 2025'
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> details;

  const _ProfileTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      children: details
          .map(
            (item) => ListTile(
              leading: Icon(item['icon'], color: Colors.teal),
              title: Text(item['title']),
              subtitle: Text(item['subtitle']),
            ),
          )
          .toList(),
    );
  }
}