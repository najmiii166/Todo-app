import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'task_home.dart'; // Import your TaskHome page

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widget bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase before running the app

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskHome(profileName: 'Default User', userUid: 'default_user_uid'), // Show TaskHome with default data
    );
  }
}
