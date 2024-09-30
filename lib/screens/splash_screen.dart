import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ambulance_app_new/Auth/loginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToLogin();
  }

  Future<void> navigateToLogin() async {
    // Delay for 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // Always navigate to LoginScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Good Care E-App'), // App name in the top bar
          centerTitle: true,
          backgroundColor: Colors.blue, // Customize the color
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo centered in the splash screen
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Image.asset('assets/logo.png'),
              ),
              SizedBox(height: 20), // Spacing between logo and text
              CircularProgressIndicator(), // Loading indicator
            ],
          ),
        ),
      ),
    );
  }
}
