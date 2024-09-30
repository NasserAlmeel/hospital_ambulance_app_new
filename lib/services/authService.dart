import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Auth/loginScreen.dart';
import '../screens/home_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check authentication state
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Sign in with email and password
  Future<void> signinWithEmail(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong: $e');
    }
  }

  // Sign up method to create a user account
  Future<void> signupWithEmail(
      String email, String password, String name, String contactDetails, double latitude, double longitude, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userId = userCredential.user?.uid;

      // Store user details in Firebase Database
      await FirebaseDatabase.instance.ref('users/$userId').set({
        'name': name,
        'contact_details': contactDetails,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'user_type': 'User', // Default user type
      });

      Fluttertoast.showToast(msg: 'Account created successfully');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating account: $e');
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  // Delete account method
  Future<void> deleteAccount(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete user data from the database
        await FirebaseDatabase.instance.ref('users/${user.uid}').remove();
        await user.delete();
        Fluttertoast.showToast(msg: 'Account deleted successfully');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error deleting account: $e');
      }
    }
  }

  // Method to update user details
  Future<void> updateUserDetails(String name, String contactDetails, double latitude, double longitude, BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseDatabase.instance.ref('users/${user.uid}').update({
          'name': name,
          'contact_details': contactDetails,
          'location': {
            'latitude': latitude,
            'longitude': longitude,
          },
        });
        Fluttertoast.showToast(msg: 'Profile updated successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error updating profile: $e');
      }
    }
  }
}
