import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/traveller_service.dart';
import '../data_model/traveller.dart';
import '../data_model/event_model.dart';
import '../services/firebase_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Traveller? _traveller;
  bool _loading = true;
  List<dynamic> _bookingEventIds = [];
  List<Event> _bookingEvents = [];
  bool _loadingBookings = false;

  @override
  void initState() {
    super.initState();
    _fetchTraveller();
  }

  Future<void> _fetchTraveller() async {
    final uid = await FirebaseAuthService().getCurrentUserId();
    if (uid != null) {
      final traveller = await TravellerService().getTraveller(uid);
      setState(() {
        _traveller = traveller;
        _loading = false;
        _bookingEventIds =
            (traveller != null && traveller.bookings != null)
                ? traveller.bookings!
                : [];
      });
      _fetchBookingEvents();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchBookingEvents() async {
    setState(() {
      _loadingBookings = true;
    });
    List<Event> events = [];
    for (var eventId in _bookingEventIds) {
      final event = await FirebaseService().getEventById(eventId);
      if (event != null) events.add(event);
    }
    setState(() {
      _bookingEvents = events;
      _loadingBookings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userName =
        _traveller?.firstName != null && _traveller?.lastName != null
            ? '${_traveller!.firstName} ${_traveller!.lastName}'
            : '';
    final String phoneNumber = _traveller?.phone ?? '';
    final String email = _traveller?.email ?? '';
    final String firstLetter =
        userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 232, 232),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset('assets/logoblack.png', height: 40),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black,
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
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await FirebaseAuthService().signOut();
                                // Navigate to login screen (replace with your login route)
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: const [
                          Icon(Icons.settings, color: Colors.black),
                          SizedBox(width: 10),
                          Text('Settings', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Fancy Profile Header
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 0, 0),
                            Color.fromARGB(255, 86, 199, 240),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32.0,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.black,
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
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            // Removed Member Gold box
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Show My Bookings directly as a list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.book_online, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(
                                    'My Bookings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_loadingBookings)
                                const Center(child: CircularProgressIndicator())
                              else if (_bookingEvents.isNotEmpty)
                                ..._bookingEvents.map(
                                  (event) => Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      leading:
                                          event.imagePath.isNotEmpty
                                              ? Image.network(
                                                event.imagePath,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              )
                                              : const Icon(
                                                Icons.book_online,
                                                color: Colors.teal,
                                              ),
                                      title: Text(event.title),
                                      subtitle: Text(
                                        '${event.location}\n${event.date.toLocal().toString().split(' ')[0]}',
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    'No bookings found.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
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
