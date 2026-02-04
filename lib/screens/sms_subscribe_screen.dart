// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'otp_entry_screen.dart'; // Import the OtpEntryScreen

// Future<String?> getUserPhone(String uid) async {
//   try {
//     final doc =
//         await FirebaseFirestore.instance
//             .collection('users-travellers')
//             .doc(uid)
//             .get();
//     if (doc.exists && doc.data() != null) {
//       return doc['phoneNumber'] as String?;
//     }
//   } catch (_) {}
//   return null;
// }

// Future<Map<String, dynamic>> sendOtpRequest(String phone) async {
//   try {
//     final url = Uri.parse(
//       'https://travelon-v2.run.place/api/mspace/otp/request',
//     );
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'phone': phone, 'isOrganizer': false}),
//     );
//     if (response.statusCode == 200) {
//       return Map<String, dynamic>.from(jsonDecode(response.body));
//     } else {
//       return {
//         'success': false,
//         'error': 'Server error',
//         'details': response.body,
//       };
//     }
//   } catch (e) {
//     return {'success': false, 'error': e.toString()};
//   }
// }

// class SmsSubscribeScreen extends StatelessWidget {
//   const SmsSubscribeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 32),
//               // Illustration (replace with asset if available)
//               Container(
//                 width: 110,
//                 height: 110,
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Icon(Icons.sms, size: 60, color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Title
//               const Text(
//                 'Subscribe to SMS Alerts',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Get instant updates about your bookings, events, and exclusive offers. Stay connected and never miss out!',
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               // Features
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _FeatureRow(
//                     icon: Icons.notifications_active,
//                     title: 'Instant Alerts',
//                     desc: 'Receive SMS notifications for bookings and updates.',
//                     iconColor: Colors.white,
//                     textColor: Colors.black,
//                   ),
//                   SizedBox(height: 18),
//                   _FeatureRow(
//                     icon: Icons.event,
//                     title: 'Event Reminders',
//                     desc: 'Never miss your favorite events and activities.',
//                     iconColor: Colors.white,
//                     textColor: Colors.black,
//                   ),
//                   SizedBox(height: 18),
//                   _FeatureRow(
//                     icon: Icons.local_offer,
//                     title: 'Exclusive Offers',
//                     desc: 'Get special deals and discounts via SMS.',
//                     iconColor: Colors.white,
//                     textColor: Colors.black,
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               // Subscribe button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final user = FirebaseAuth.instance.currentUser;
//                     if (user == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('User not logged in.')),
//                       );
//                       return;
//                     }
//                     final phone = await getUserPhone(user.uid);
//                     if (phone == null || phone.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('No phone number found.')),
//                       );
//                       return;
//                     }
//                     final response = await sendOtpRequest(phone);
//                     if (response['success'] == true) {
//                       final sessionId = response['sessionId'];
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (_) => OtpEntryScreen(
//                                 sessionId: sessionId,
//                                 phone: phone,
//                               ),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             response['error'] ?? 'Failed to send OTP',
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Subscribe',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Skip button
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.pushReplacementNamed(context, '/home');
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.black, width: 2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Skip',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FeatureRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String desc;
//   final Color iconColor;
//   final Color textColor;
//   const _FeatureRow({
//     required this.icon,
//     required this.title,
//     required this.desc,
//     this.iconColor = Colors.white,
//     this.textColor = Colors.black,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//           ),
//           padding: const EdgeInsets.all(10),
//           child: Icon(icon, color: iconColor, size: 22),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 desc,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: textColor.withOpacity(0.7),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Future<String?> getUserPhone(String uid) async {
//     try {
//       final doc =
//           await FirebaseFirestore.instance
//               .collection('users-travellers')
//               .doc(uid)
//               .get();
//       if (doc.exists && doc.data() != null) {
//         return doc['phoneNumber'] as String?;
//       }
//     } catch (_) {}
//     return null;
//   }

//   Future<Map<String, dynamic>> sendOtpRequest(String phone) async {
//     try {
//       final url = Uri.parse(
//         'https://travelon-v2.run.place/api/mspace/otp/request',
//       );
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'phone': phone, 'isOrganizer': false}),
//       );
//       if (response.statusCode == 200) {
//         return Map<String, dynamic>.from(jsonDecode(response.body));
//       } else {
//         return {
//           'success': false,
//           'error': 'Server error',
//           'details': response.body,
//         };
//       }
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
// }
