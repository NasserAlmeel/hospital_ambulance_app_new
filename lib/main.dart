import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ambulance_app_new/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase without passing options since we've removed it
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Good Care E-App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}
