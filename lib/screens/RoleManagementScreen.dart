import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RoleManagementScreen extends StatefulWidget {
  @override
  _RoleManagementScreenState createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  List<UserRole> users = []; // List to store users with their roles
  final DatabaseReference userRef = FirebaseDatabase.instance.ref('users');

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    DataSnapshot snapshot = await userRef.once();
    if (snapshot.exists) {
      final userMap = snapshot.value as Map<dynamic, dynamic>;
      users = userMap.entries.map((entry) {
        return UserRole(entry.key, entry.value['name'], entry.value['role'] ?? 'User');
      }).toList();
      setState(() {});
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    await userRef.child(userId).update({'role': role});
    Fluttertoast.showToast(msg: 'Role updated successfully');

    // Create a log entry for the role change
    String timestamp = DateTime.now().toIso8601String();
    await logRef.child(timestamp).set({
      'action': 'Updated role for user $userId to $role',
      'timestamp': timestamp,
    });

    fetchUsers(); // Refresh the list
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage User Roles')),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            subtitle: Text('Current Role: ${users[index].role}'),
            trailing: DropdownButton<String>(
              value: users[index].role,
              items: ['Admin', 'User', 'Editor'].map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newRole) {
                if (newRole != null) {
                  updateUserRole(users[index].userId, newRole);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class UserRole {
  final String userId;
  final String name;
  final String role;

  UserRole(this.userId, this.name, this.role);
}
