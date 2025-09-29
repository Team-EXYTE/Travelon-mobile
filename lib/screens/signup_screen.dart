import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sms_subscribe_screen.dart'; // Import the new screen

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
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
      final phoneNumber = _phoneController.text.trim();
      String formattedPhone = '';
      if (phoneNumber.isNotEmpty) {
        // Remove any leading 0, spaces, or +
        String cleaned = phoneNumber.replaceAll(RegExp(r'^[0+\s]+'), '');
        formattedPhone = '94$cleaned';
      }
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phoneNumber.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
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
              debugPrint('Signup successful for user: \\${user.uid}');
              try {
                await FirebaseFirestore.instance
                    .collection('users-travellers')
                    .doc(user.uid)
                    .set({
                      'id': user.uid,
                      'firstName': firstName,
                      'lastName': lastName,
                      'email': email,
                      'phoneNumber': formattedPhone,
                      'bookings': [],
                      'joinDate': DateTime.now().toIso8601String(),
                    });
                debugPrint('User data saved to Firestore.');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Signup successful!")));
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SmsSubscribeScreen()),
                );
              } catch (firestoreError) {
                debugPrint('Firestore error: \\${firestoreError}');
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Define a consistent input decoration theme for this page
    final inputDecorationTheme = InputDecoration(
      labelStyle: TextStyle(color: Colors.black54),
      hintStyle: TextStyle(color: Colors.black38),
      prefixIconColor: Colors.black54,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/srilanka.jpg',
                  height: screenHeight * 0.30,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            // Form Section
            Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset('assets/logoblack.png', height: 60),
                      SizedBox(height: 8),
                      Text(
                        "Create your Travelon account",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your first name'
                                : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
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
                      prefixText: '+94 ',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter your phone number';
                      if (value.length < 9) return 'Enter a valid phone number';
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
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: _validateEmail,
                      ),

                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),

                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain an uppercase letter.';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain a number.';
                          }
                          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Password must contain a special character.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Sign Up",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ",
                              style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacementNamed(context, '/login'),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}