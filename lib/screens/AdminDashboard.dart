import 'package:flutter/material.dart';
import 'RequestManagementScreen.dart';
import 'UserManagementScreen.dart'; // Import User Management Screen
import 'LogManagementScreen.dart';   // Import Log Management Screen

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Admin Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserManagementScreen()),
                );
              },
              child: Text('Manage Users'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RequestManagementScreen()),
                );
              },
              child: Text('Manage Requests'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LogManagementScreen()),
                );
              },
              child: Text('View Logs'),
            ),
          ],
        ),
      ),
    );
  }
}
