
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'SignupPage.dart'; // Import the Signup Page
import 'task_home.dart'; // Import the TaskHome Page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Perform login by checking Firestore
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Query the Firestore collection for user data
        final QuerySnapshot userQuery = await _firestore
            .collection('users') // Assumes user data is stored in a "users" collection
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (userQuery.docs.isNotEmpty) {
          // Check if password matches
          final user = userQuery.docs.first.data() as Map<String, dynamic>;
          if (user['password'] == _passwordController.text.trim()) {
            // Successful login, navigate to the dashboard and pass userUid
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskHome(
                  profileName: userQuery.docs.first['name'], // Assuming 'name' is the field for profile name
                  userUid: userQuery.docs.first.id, // Use the document ID as userUid
                ),
              ),
            );
          } else {
            // Incorrect password
            _showError("Incorrect email or password.");
          }
        } else {
          // No user found
          _showError("Incorrect email or password.");
        }
      } catch (e) {
        // Handle database connection error
        _showError("An error occurred: $e");
      }
    }
  }

  // Show an error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "My App",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 32.0),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16.0),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 32.0),

              // Login button
              ElevatedButton(
                onPressed: _login,
                child: Text("Login", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 16.0),

              // Signup button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}