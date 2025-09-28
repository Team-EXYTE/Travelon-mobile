import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_entry_screen.dart'; // Import the OtpEntryScreen

class SmsSubscribeScreen extends StatelessWidget {
  const SmsSubscribeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Subscribe to SMS Updates')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sms, size: 64, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              'Would you like to subscribe to our SMS service to get real-time event details?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.check, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not logged in.')),
                  );
                  return;
                }
                final phone = await getUserPhone(user.uid);
                if (phone == null || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No phone number found.')),
                  );
                  return;
                }
                final response = await sendOtpRequest(phone);
                if (response['success'] == true) {
                  final sessionId = response['sessionId'];
                  // Navigate to OTP entry screen, passing sessionId and phone
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OtpEntryScreen(
                            sessionId: sessionId,
                            phone: phone,
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['error'] ?? 'Failed to send OTP'),
                    ),
                  );
                }
              },
              label: const Text(
                'Subscribe',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Skip for now', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getUserPhone(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users-travellers')
              .doc(uid)
              .get();
      if (doc.exists && doc.data() != null) {
        return doc['phoneNumber'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> sendOtpRequest(String phone) async {
    try {
      final url = Uri.parse(
        'https://travelon-v2.run.place/api/mspace/otp/request',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'isOrganizer': false}),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        return {
          'success': false,
          'error': 'Server error',
          'details': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
