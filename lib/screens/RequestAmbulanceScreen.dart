import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

class RequestAmbulanceScreen extends StatefulWidget {
  @override
  _RequestAmbulanceScreenState createState() => _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool isLoading = false;

  Future<void> requestAmbulance() async {
    setState(() {
      isLoading = true;
    });

    String location = locationController.text.trim();
    String details = detailsController.text.trim();

    if (location.isEmpty || details.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Add request to Firebase Database under 'requests' collection
      await FirebaseDatabase.instance.ref('requests').push().set({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'location': location,
        'details': details,
        'status': 'pending',
        'timestamp': DateTime.now().toString(),
      });

      Fluttertoast.showToast(msg: 'Ambulance requested successfully!');
      Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Ambulance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Emergency Location'),
            ),
            TextField(
              controller: detailsController,
              decoration: InputDecoration(labelText: 'Additional Details'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: requestAmbulance,
              child: Text('Request Ambulance'),
            ),
          ],
        ),
      ),
    );
  }
}
