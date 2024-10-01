import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestManagementScreen extends StatefulWidget {
  @override
  _RequestManagementScreenState createState() => _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen> {
  final DatabaseReference requestRef = FirebaseDatabase.instance.ref('requests');
  List<Map<dynamic, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    requestRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        requests = data.entries
            .map((entry) => {
          'id': entry.key,
          ...entry.value as Map<dynamic, dynamic>,
        })
            .toList();
      } else {
        requests = [];
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> approveRequest(String requestId) async {
    await requestRef.child(requestId).update({'status': 'approved'});
    Fluttertoast.showToast(msg: 'Request approved successfully!');
  }

  Future<void> rejectRequest(String requestId) async {
    await requestRef.child(requestId).update({'status': 'rejected'});
    Fluttertoast.showToast(msg: 'Request rejected successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Management')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Request ID: ${request['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: ${request['userName']}'),
                  Text('Location: ${request['location']}'),
                  Text('Status: ${request['status']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => approveRequest(request['id']),
                    child: Text('Approve'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => rejectRequest(request['id']),
                    child: Text('Reject'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
