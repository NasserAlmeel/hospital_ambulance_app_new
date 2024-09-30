import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('users');
  User? currentUser;
  String? userId;

  String name = '';
  String contact = '';
  String liveLocation = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      userId = currentUser!.uid;
      fetchUserData(userId!);
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      DatabaseEvent event = await _databaseRef.child(userId).once();
      final userData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (userData != null) {
        setState(() {
          name = userData['name'] ?? '';
          contact = userData['contact'] ?? '';
          liveLocation = userData['liveLocation'] ?? '';
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch user data: $e');
    }
  }

  Future<void> updateUserData() async {
    if (userId != null) {
      try {
        await _databaseRef.child(userId!).update({
          'name': name,
          'contact': contact,
          'liveLocation': liveLocation,
        });
        Fluttertoast.showToast(msg: 'Profile updated successfully!');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name:', style: TextStyle(fontSize: 18)),
            TextField(
              onChanged: (value) => setState(() => name = value),
              controller: TextEditingController(text: name),
            ),
            SizedBox(height: 10),
            Text('Contact:', style: TextStyle(fontSize: 18)),
            TextField(
              onChanged: (value) => setState(() => contact = value),
              controller: TextEditingController(text: contact),
            ),
            SizedBox(height: 10),
            Text('Live Location:', style: TextStyle(fontSize: 18)),
            TextField(
              onChanged: (value) => setState(() => liveLocation = value),
              controller: TextEditingController(text: liveLocation),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserData,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
