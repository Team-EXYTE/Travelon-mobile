import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'TRAVELON',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Align title to the left (remove centerTitle)
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Handle favorite action
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // TODO: Handle notifications action
            },
          ),
          SizedBox(width: 8), // small spacing on right
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                    hintText: 'Search events near you...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Hero card
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.asset(
                      'assets/hero.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        'Kandy Perahera\nThe Kandy perahera is a grand Buddhist festival in Sri Lanka...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Locations
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
                  _locationItem('assets/location2.jpg', 'Peradeniya'),
                  _locationItem('assets/location3.jpeg', 'Mirissa'),
                  _locationItem('assets/location4.jpeg', 'Anuradhapura'),
                  _locationItem('assets/location5.jpg', 'Jaffna'),
                  _locationItem('assets/location6.jpg', 'Colombo'),
                ],
              ),
            ),

            // More Events
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Upcoming Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _eventCard('assets/event1.jpeg', 'Batik Workshop', '\$10.99'),
                  _eventCard('assets/event2.jpg', 'Cooking Class', '\$21.99'),
                  _eventCard('assets/event3.avif', 'Sightseeing', '\$14.99'),
                  _eventCard('assets/event5.jpg', 'Dalada Perahera', '\$16.99'),
                  _eventCard(
                    'assets/event4.webp',
                    'Kohomba kankariya',
                    '\$5.99',
                  ),
                  _eventCard('assets/event6.jpg', 'Thaipongal', '\$8.99'),
                ],
              ),
            ),

          // Categories title
Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Text(
    'Categories',
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),

// Color-coded category cards
SizedBox(
  height: 50,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 16),
    children: [
      _categoryCard('Festivals', Colors.deepPurple),
      _categoryCard('Music', Colors.indigo),
      _categoryCard('Cultural', Colors.teal),
      _categoryCard('Wellness', Colors.pinkAccent),
      _categoryCard('Nature', Colors.green),
      _categoryCard('Food & Drink', Colors.orange),
    ],
  ),
),



            // Recently Ended title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Recently Ended',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            // Recently Ended horizontal list
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _eventCard(
                    'assets/ended1.jpg',
                    'Aurudu Festival',
                    'April 14',
                  ),
                  _eventCard('assets/ended2.jpg', 'Vesak', 'May 5'),
                  _eventCard('assets/ended3.jpg', 'Poson Dansal', 'June 11'),
                ],
              ),
            ),

            SizedBox(height: 70), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures even spacing for 4 items
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

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

Widget _categoryCard(String label, Color color) {
  return Padding(
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
  );
}



  Widget _eventCard(String imagePath, String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          Text(price, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
