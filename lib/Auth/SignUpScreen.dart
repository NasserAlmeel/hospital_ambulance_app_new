import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore (alternatively use Realtime Database)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart'; // To get user's location

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LocationData? currentLocation;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase Authentication for creating the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      // Store additional user info in Firestore
      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid); // Users stored by UID

        // Check if user already exists
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          Fluttertoast.showToast(msg: 'User already exists');
        } else {
          // Add user information in Firestore
          await docRef.set({
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'location': {
              'latitude': currentLocation?.latitude,
              'longitude': currentLocation?.longitude
            },
            'createdAt': FieldValue.serverTimestamp(),
          });

          Fluttertoast.showToast(msg: 'Account created successfully');
          // Navigate to HomePage or other screen
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sign-up failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: isLoading
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
