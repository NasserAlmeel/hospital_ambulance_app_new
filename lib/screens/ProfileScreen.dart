// profileScreen.dart
import 'package:flutter/material.dart';
import 'package:hospital_ambulance_app_new/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? phoneNumber;
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch user information from Firebase Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      DatabaseEvent event = await userRef.once();
      if (event.snapshot.value != null) {
        final userData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          name = userData['name'];
          email = userData['email'];
          phoneNumber = userData['phoneNumber'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.update({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
              controller: TextEditingController(text: name),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
              controller: TextEditingController(text: email),
              readOnly: true, // Prevent email from being changed
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Phone Number'),
              onChanged: (value) => phoneNumber = value,
              controller: TextEditingController(text: phoneNumber),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: updateUserInfo,
                  child: Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    AuthService().signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
