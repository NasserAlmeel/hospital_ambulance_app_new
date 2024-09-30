import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ambulance_app_new/services/authService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import for Google Maps
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String userType; // Variable to store user type
  late String userName; // Variable to store user's name
  int _selectedIndex = 0; // Index for Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen initializes
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName = user.displayName ?? 'User'; // Fallback to 'User' if displayName is null
      userType = await getUserTypeFromDatabase(user.uid); // Fetch user type
      setState(() {});
    } else {
      Fluttertoast.showToast(msg: 'No user logged in.');
    }
  }

  Future<String> getUserTypeFromDatabase(String uid) async {
    // Example function to get the user type from Firebase Database
    return 'User'; // Hardcoded for demonstration; replace with actual logic
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Care E-App'),
      ),
      body: _selectedIndex == 0
          ? (userType == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching user data
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hi, $userName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: userType == 'User'
                ? UserView() // Show User layout
                : userType == 'Driver'
                ? DriverView() // Show Driver layout
                : AdminView(), // Show Admin layout
          ),
        ],
      ))
          : ProfileView(), // Profile Screen

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget for the User view
class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Request Emergency Assistance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            // Logic to request emergency assistance
            print("Emergency assistance requested");
            Fluttertoast.showToast(msg: 'Emergency assistance requested!');
          },
          child: Text('Request'),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Example coordinates
              zoom: 14,
            ),
            // Add additional Google Map settings and markers as needed
          ),
        ),
      ],
    );
  }
}

// Widget for the Driver view
class DriverView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Incoming Emergency Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            // Logic to accept a request
            print("Request accepted");
            Fluttertoast.showToast(msg: 'Request accepted!');
          },
          child: Text('Accept Request'),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Example coordinates
              zoom: 14,
            ),
            // Add additional Google Map settings and markers as needed
          ),
        ),
      ],
    );
  }
}

// Widget for the Admin view
class AdminView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Admin Dashboard',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Widget for the Profile view
class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'User Profile',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
