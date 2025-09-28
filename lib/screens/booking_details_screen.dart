import 'package:flutter/material.dart';
import '../data_model/event_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/traveller_service.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Event event;
  const BookingDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  List<String> _ticketIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTicketIds();
  }

  Future<void> _fetchTicketIds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ids = await TravellerService().getTicketIdsForEvent(
      user.uid,
      widget.event.id,
    );
    setState(() {
      _ticketIds = ids;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Details')),
      backgroundColor: Colors.white,
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.event.imagePath.isNotEmpty)
                      Center(
                        child: Image.network(
                          widget.event.imagePath,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Location: ${widget.event.location}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${widget.event.date.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your Ticket IDs:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_ticketIds.isEmpty)
                      Text(
                        'No tickets found.',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 185, 198, 192),
                        ),
                      ),
                    ..._ticketIds.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final id = entry.value;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(222, 5, 16, 48),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              idx.toString(),
                              style: TextStyle(
                                color: Color(0xFF1A2956),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            id,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Event: ${widget.event.title}\nDate: ${widget.event.date.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Text(
                            'ID',
                            style: TextStyle(
                              color: Colors.yellow[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
    );
  }
}
