import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LogManagementScreen extends StatefulWidget {
  @override
  _LogManagementScreenState createState() => _LogManagementScreenState();
}

class _LogManagementScreenState extends State<LogManagementScreen> {
  List<LogEntry> logs = []; // List to store logs
  final DatabaseReference logRef = FirebaseDatabase.instance.ref('logs');

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    DatabaseEvent event = await logRef.once(); // Fetch the logs as a DatabaseEvent
    DataSnapshot snapshot = event.snapshot; // Get the DataSnapshot from the DatabaseEvent

    if (!snapshot.exists) {
      // Create a new logs collection if it doesn't exist
      await logRef.set({}); // Initialize the logs collection
      Fluttertoast.showToast(msg: 'Log collection created.');
    } else {
      final logMap = snapshot.value as Map<dynamic, dynamic>;
      logs = logMap.entries.map((entry) {
        return LogEntry(entry.value['action'], entry.value['timestamp']);
      }).toList();
    }
    setState(() {});
  }

  Future<void> exportLogs() async {
    final String csv = ListToCsvConverter().convert(logs.map((log) => [log.action, log.timestamp]).toList());
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/logs.csv');
    await file.writeAsString(csv);
    Fluttertoast.showToast(msg: 'Logs exported to ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Logs'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: exportLogs,
          ),
        ],
      ),
      body: logs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logs[index].action),
            subtitle: Text(logs[index].timestamp),
          );
        },
      ),
    );
  }
}

class LogEntry {
  final String action;
  final String timestamp;

  LogEntry(this.action, this.timestamp);
}

// Helper class to convert List to CSV
class ListToCsvConverter {
  String convert(List<List<dynamic>> data) {
    return data.map((row) => row.map((field) => '"$field"').join(',')).join('\n');
  }
}
