import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully!");
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }

  runApp(const TravelonApp());
}

class TravelonApp extends StatelessWidget {
  const TravelonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travelon',
      theme: ThemeData(primarySwatch: Colors.blue), // Changed from grey
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(), // Add const
        '/signup': (context) => const SignupPage(), // Add const
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const UserProfilePage(),
      },
    );
  }
}