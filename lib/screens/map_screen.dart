import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({Key? key}) : super(key: key);

  @override
  _OpenStreetMapScreenState createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  // Example nearby event locations (replace with your actual event coordinates)
  final List<LatLng> _nearbyEvents = [
    LatLng(6.9271, 79.8612),  // Colombo (example)
    LatLng(6.9295, 79.8576),  // Another event nearby
    LatLng(6.7106, 79.9074),  // And one more
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // (Your existing code for determining position remains the same)

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

    _mapController.move(_currentLocation!, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreetMap View'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    // Your current location marker - red
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),

                    // Event markers - green
                    ..._nearbyEvents.map((eventLocation) => Marker(
                          point: eventLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 30,
                          ),
                        )),
                  ],
                ),
              ],
            ),
    );
  }
}
