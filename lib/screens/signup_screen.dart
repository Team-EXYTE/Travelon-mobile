import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _showPassword = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
        return;
      }

      // Dummy OTP step
      String? otp = await showDialog<String>(
        context: context,
        builder: (context) {
          final otpController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter OTP'),
            content: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP (123456)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, otpController.text.trim()),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
      if (otp == null || otp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup cancelled: OTP required.")),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signing up...")));
      debugPrint('Attempting signup for email: $email');
      _authService
          .signUpWithEmail(email, password)
          .then((user) async {
            if (user != null) {
              debugPrint('Signup successful for user: ${user.uid}');
              try {
                await FirebaseFirestore.instance
                    .collection('users-travellers')
                    .doc(user.uid)
                    .set({
                      'id': user.uid,
                      'firstName': firstName,
                      'lastName': lastName,
                      'email': email,
                      'phone': phone,
                      'bookings': [],
                    });
                debugPrint('User data saved to Firestore.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Signup successful! Please login.")),
                );
                Navigator.pushReplacementNamed(context, '/login');
              } catch (firestoreError) {
                debugPrint('Firestore error: $firestoreError');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error saving user data: $firestoreError"),
                  ),
                );
              }
            } else {
              debugPrint('Signup failed: user is null');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Signup failed")));
            }
          })
          .catchError((e) {
            debugPrint('Signup error: $e');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Signup error: $e")));
          });
    }
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r"^.+@gmail\.com$");
    if (value == null || value.isEmpty) return "Please enter your email";
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logoblack.png', height: 70),
                  SizedBox(height: 8),
                  Text(
                    "Create your Travelon account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your first name'
                                : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your last name'
                                : null,
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter your phone number';
                      if (value.length < 10)
                        return 'Enter a valid phone number';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter a password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Sign Up",style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
