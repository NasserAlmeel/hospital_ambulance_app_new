import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MapUtils {
  MapUtils._();

  // Method to open Google Maps with given latitude and longitude
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  // Method to get the user's current location
  static Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if the service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null; // Service not enabled
      }
    }

    // Check for location permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null; // Permission denied
      }
    }

    // Get current location
    return await location.getLocation();
  }

  // Method to save user's location to Firebase Realtime Database
  static Future<void> saveLocationToDatabase(double latitude, double longitude) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      try {
        await FirebaseDatabase.instance.ref('users/$userId/location').set({
          'latitude': latitude,
          'longitude': longitude,
        });
      } catch (e) {
        throw 'Error saving location to database: $e';
      }
    } else {
      throw 'User not authenticated.';
    }
  }
}
