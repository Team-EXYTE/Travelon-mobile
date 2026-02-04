// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class OtpEntryScreen extends StatefulWidget {
//   final String sessionId;
//   final String phone;
//   const OtpEntryScreen({Key? key, required this.sessionId, required this.phone})
//     : super(key: key);

//   @override
//   State<OtpEntryScreen> createState() => _OtpEntryScreenState();
// }

// class _OtpEntryScreenState extends State<OtpEntryScreen> {
//   final _otpController = TextEditingController();
//   bool _isLoading = false;
//   String? _error;

//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   Future<void> _verifyOtp() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     final otp = _otpController.text.trim();
//     if (otp.isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _error = 'Please enter the OTP.';
//       });
//       return;
//     }
//     try {
//       final url = Uri.parse(
//         'https://travelon-v2.run.place/api/mspace/otp/verify',
//       );
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'otp': otp,
//           'sessionId': widget.sessionId,
//           // 'phone': widget.phone,
//         }),
//       );
//       final result = jsonDecode(response.body);
//       if (response.statusCode == 200 && result['success'] == true) {
//         // Success: show confirmation and go to home
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Subscription confirmed!')));
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//       } else {
//         setState(() {
//           _error = result['error'] ?? 'Invalid OTP or verification failed.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Error verifying OTP: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Enter OTP')),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter the OTP sent to your phone',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'OTP',
//                 border: OutlineInputBorder(),
//                 errorText: _error,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyOtp,
//                 child:
//                     _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Verify'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
