import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ambulance_app_new/screens/profileScreen.dart';
import 'package:hospital_ambulance_app_new/screens/requestAmbulanceScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userType; // Will determine the layout based on user type
  int _selectedIndex = 0; // For bottom navigation
  bool isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  Future<void> getUserType() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseDatabase.instance.ref('users/$userId').once();

    if (snapshot.snapshot.value != null) {
      final userData = snapshot.snapshot.value as Map<String, dynamic>; // Casting to Map
      setState(() {
        userType = userData['userType']; // Now you can access the 'userType' field
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading if no data is found
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Choose the body based on user type
    Widget body;

    if (isLoading) {
      body = Center(child: CircularProgressIndicator());
    } else if (userType == null) {
      body = Center(child: Text('User type not found.'));
    } else if (userType == 'Admin') {
      body = AdminDashboard(); // Admin Dashboard
    } else if (userType == 'Driver') {
      body = DriverDashboard(); // Driver Dashboard
    } else {
      body = UserDashboard(); // Regular User Dashboard
    }

    return Scaffold(
      appBar: AppBar(title: Text('Good Care E-App')),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
          }
        },
      ),
    );
  }
}

// User Dashboard for regular users
class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}!'),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestAmbulanceScreen()));
            },
            child: Text('Request Ambulance'),
          ),
        ],
      ),
    );
  }
}

// Admin Dashboard for admins
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Admin Dashboard - Manage the system here.'));
  }
}

// Driver Dashboard for drivers
class DriverDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Driver Dashboard - View requests here.'));
  }
}
