import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _showPassword = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      _authService
          .signInWithEmail(email, password)
          .then((user) {
            setState(() => _isLoading = false);
            if (user != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Login successful!")));
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid email or password")),
              );
            }
          })
          .catchError((e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          });
    }
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
                          SizedBox(height: 16),
                          Text(
                            "Welcome back! Please login to your account",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(),
                            ),
                          if (!_isLoading) ...[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your email';
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value))
                                  return 'Please enter a valid email';
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your password';
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(value: false, onChanged: (value) {}),
                                Text("Remember me"),
                                Spacer(),
                                TextButton(onPressed: () {}, child: Text("Forgot password?"))
                              ],
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text("Login"), SizedBox(width: 8), Icon(Icons.arrow_forward)],
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? "),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/signup'),
                                  child: Text("Sign up", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

  }

