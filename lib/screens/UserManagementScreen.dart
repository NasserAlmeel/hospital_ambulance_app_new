import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseReference userRef = FirebaseDatabase.instance.ref('users');
  List<Map<dynamic, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    userRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        users = data.entries
            .map((entry) => {
          'uid': entry.key,
          ...entry.value as Map<dynamic, dynamic>,
        })
            .toList();
      } else {
        users = [];
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> deleteUser(String uid) async {
    await userRef.child(uid).remove();
    Fluttertoast.showToast(msg: 'User deleted successfully!');
  }

  void showEditDialog(Map<dynamic, dynamic> user) {
    final TextEditingController nameController = TextEditingController(text: user['name']);
    final TextEditingController emailController = TextEditingController(text: user['email']);
    final TextEditingController phoneController = TextEditingController(text: user['phone']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateUser(user['uid'], nameController.text, emailController.text, phoneController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUser(String uid, String name, String email, String phone) async {
    await userRef.child(uid).update({
      'name': name,
      'email': email,
      'phone': phone,
    });
    Fluttertoast.showToast(msg: 'User updated successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => showEditDialog(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteUser(user['uid']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
