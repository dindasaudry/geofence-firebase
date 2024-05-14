import 'dart:async';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSelectionPage extends StatefulWidget {
  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  GoogleMapController? _mapController;
  Set<Marker> markers = {}; // This set will hold the marker for the user location

  // Add a variable to store user's current location
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        markers.add(Marker(
          markerId: MarkerId('userLocation'),
          position: currentLocation!, // Use the currentLocation variable here
        ));
      });
      // Update camera position to focus on the user's location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation!, // Use the currentLocation variable here
              zoom: 18.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
    return "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}";
  } catch (e) {
    print("Error getting address: $e");
    return "Address not available";
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Stack(
        children: [
          // Check if currentLocation is available before showing the map
          if (currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation!, // Use the currentLocation variable here
                zoom: 13.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              markers: markers, // Add the markers set
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
  if (currentLocation != null) {
    final message =
        'Selected location is approximate due to limited geolocation API accuracy.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );

    // Retrieve address from coordinates asynchronously
    String address = await _getAddressFromCoordinates(
        currentLocation!.latitude, currentLocation!.longitude);

    Navigator.pop(context, {
      'latitude': currentLocation!.latitude,
      'longitude': currentLocation!.longitude,
      'address': address,
    });
  }
},

        label: Text('Confirm Location (Limited Accuracy)'),
        icon: Icon(Icons.check),
      ),
    );
  }
}