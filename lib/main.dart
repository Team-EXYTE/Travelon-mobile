import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/login_screen.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      // initialRoute: '/login',
      // routes: {
      //   '/login': (context) => LoginPage(),
      //   '/signup': (context) => SignupPage(),
      // },
      home: const HomeScreen(),
    );
  }
}
