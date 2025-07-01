import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TravelonApp());
}

class TravelonApp extends StatelessWidget {
  const TravelonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travelon',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomeScreen(),
    );
  }
}
