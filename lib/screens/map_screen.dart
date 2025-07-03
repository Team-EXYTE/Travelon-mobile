import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../data_model/event_model.dart';
import '../services/event_service.dart';
import '../screens/event_detail_screen.dart';

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  _OpenStreetMapScreenState createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  List<Event> _events = [];
  String _currentFilter = 'Upcoming Events'; // Track current filter

  @override
  void initState() {
    super.initState();
    _events =
        EventService.getUpcomingEvents(); // Show only upcoming events by default
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_currentLocation!, 12);
  }

  void _onEventMarkerTapped(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EventDetailScreen(
              imagePath: event.imagePath,
              title: event.title,
              price: event.price,
              event: event,
            ),
      ),
    );
  }

  Widget _buildEventMarker(Event event) {
    return GestureDetector(
      onTap: () => _onEventMarkerTapped(event),
      child: Container(
        decoration: BoxDecoration(
          color:
              event.isEnded
                  ? Colors.grey
                  : EventService.getCategoryColor(
                    EventService.categories
                        .firstWhere((cat) => cat.name == event.category)
                        .color,
                  ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          event.isEnded ? Icons.event_busy : Icons.event,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('All Events'),
                trailing:
                    _currentFilter == 'All Events'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () {
                  setState(() {
                    _events = EventService.allEvents;
                    _currentFilter = 'All Events';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Upcoming Events'),
                trailing:
                    _currentFilter == 'Upcoming Events'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () {
                  setState(() {
                    _events = EventService.getUpcomingEvents();
                    _currentFilter = 'Upcoming Events';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Ended Events'),
                trailing:
                    _currentFilter == 'Ended Events'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () {
                  setState(() {
                    _events = EventService.getEndedEvents();
                    _currentFilter = 'Ended Events';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Map'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body:
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          // Current location marker
                          Marker(
                            point: _currentLocation!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          // Event markers
                          ..._events.map(
                            (event) => Marker(
                              point: LatLng(event.latitude, event.longitude),
                              width: 40,
                              height: 40,
                              child: _buildEventMarker(event),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Legend
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legend',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Your Location',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Active Events',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Ended Events',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Event count indicator
                  Positioned(
                    bottom: 80,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_events.length} ${_currentFilter.toLowerCase()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
