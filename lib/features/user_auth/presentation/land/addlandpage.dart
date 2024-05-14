import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc; // Alias added

class UkurKebun extends StatefulWidget {
  @override
  _UkurKebunState createState() => _UkurKebunState();
}

class _UkurKebunState extends State<UkurKebun> {
  Completer<GoogleMapController> mapController = Completer();
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  List<LatLng> polygonPoints = [];
  double _totalDistance = 0;
  double _area = 0;
  double _perimeter = 0;
  late CameraPosition initialCameraPosition; // Add this line
  
 @override
 void initState() {
    super.initState();
    _getCurrentLocation(); // Call this method in initState
 }

 void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      // Update the initial camera position to the current location
      initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 18,
      );
    });
 }

  void _calculateMetrics() {
    if (polygonPoints.length < 2) {
      _totalDistance = 0;
      _area = 0;
      _perimeter = 0;
      return;
    }

    _totalDistance = 0;
    _area = 0;
    _perimeter = 0;

    for (int i = 0; i < polygonPoints.length - 1; i++) {
      _totalDistance +=
          _calculateDistance(polygonPoints[i], polygonPoints[i + 1]);
    }

    _perimeter = _totalDistance +
        _calculateDistance(polygonPoints.last, polygonPoints.first);

    if (polygonPoints.length >= 3) {
      _area = _calculateArea(polygonPoints);
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
  }

// Panjang 1 derajat Latitude dan Longitude dalam meter (perkiraan)
  final double metersPerDegreeLatitude = 111195; // Dianggap konstan
  final double metersPerDegreeLongitude = 111320; // Dianggap konstan

  double _calculateArea(List<LatLng> points) {
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      double x1 = points[i].longitude * metersPerDegreeLongitude;
      double y1 = points[i].latitude * metersPerDegreeLatitude;
      double x2 = points[j].longitude * metersPerDegreeLongitude;
      double y2 = points[j].latitude * metersPerDegreeLatitude;

      area += (x1 + x2) * (y2 - y1);
    }

    area = (area / 2).abs();
    return area;
  }

  String _formatDistance(double distance) {
    if (distance >= 1000) {
      double kilometers = distance / 1000;
      return '${kilometers.toStringAsFixed(2)} km';
    } else {
      return '${distance.toStringAsFixed(2)} m';
    }
  }

  String _formatArea(double area) {
    double threshold = 0.001;

    if (area < threshold) {
      // Tampilkan dalam m² jika area sangat kecil
      return '${area.toStringAsFixed(6)} m²'; // Tampilkan 6 desimal
    } else if (area < 10000) {
      // Tampilkan dalam m² jika area kurang dari 10.000 m²
      return '${area.toStringAsFixed(2)} m²'; // Tampilkan 2 desimal
    } else {
      // Konversi ke hektar jika area cukup besar
      double hectares = area / 10000;
      return '${hectares.toStringAsFixed(2)} ha'; // Tampilkan 2 desimal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Ukur Lahan',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 17.35,
                fontWeight: FontWeight.w500),
          ),
          elevation: 1,
          shadowColor: Colors.black,
          toolbarHeight: 40,
          titleSpacing: 0,

          // titleSpacing: 2,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "PolygonsCoordinate": polygonPoints,
                    "LuasKebun": _area
                  });
                },
                icon: Icon(
                  CupertinoIcons.doc,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
                onPressed: () {
                  _clearMarkersAndPolygon();
                },
                icon: Icon(
                  CupertinoIcons.trash,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ]),
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // Posisi shadow (x, y)
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Keliling: ${_formatDistance(_perimeter)}',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13.1,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  'Luas: ${_formatArea(_area)}',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13.1,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
              initialCameraPosition: initialCameraPosition,
              mapType: MapType.hybrid,
              markers: markers,
              polygons: polygons,
              onTap: _addMarkerAndPolygonPoint,
            ),
          ),
        ],
      ),
    );
  }

  void _addMarkerAndPolygonPoint(LatLng point) {
    setState(() {
      // Menambahkan marker pada titik yang ditekan
      final markerId = MarkerId(point.toString());
      final marker = Marker(
        markerId: markerId,
        position: point,
        icon: BitmapDescriptor.defaultMarker,
        draggable: true,
        onDragEnd: (newPosition) {
          _updatePolygonPoint(point, newPosition);
        },
      );
      markers.add(marker);

      // Menambahkan titik ke dalam list untuk polygon
      polygonPoints.add(point);

      // Mengupdate polygon jika sudah ada lebih dari 2 titik
      if (polygonPoints.length > 2) {
        _updatePolygon();
      }
      _calculateMetrics();
    });
  }

  void _updatePolygonPoint(LatLng oldPosition, LatLng newPosition) {
    setState(() {
      // Hapus titik lama dan marker yang sesuai
      final markerId = MarkerId(oldPosition.toString());
      markers.removeWhere((marker) => marker.markerId == markerId);
      polygonPoints.removeWhere((point) =>
          point.latitude == oldPosition.latitude &&
          point.longitude == oldPosition.longitude);

      // Tambahkan titik baru dan marker yang sesuai
      polygonPoints.add(newPosition);
      final newMarkerId = MarkerId(newPosition.toString());
      final newMarker = Marker(
        markerId: newMarkerId,
        position: newPosition,
        icon: BitmapDescriptor.defaultMarker,
        draggable: true,
        onDragEnd: (newPosition) {
          _updatePolygonPoint(newPosition, newPosition);
        },
      );
      markers.add(newMarker);

      // Mengupdate polygon jika sudah ada lebih dari 2 titik
      if (polygonPoints.length > 2) {
        _updatePolygon();
      }
      _calculateMetrics();
    });
  }

  void _updatePolygon() {
    setState(() {
      final polygonId = PolygonId('polygon');
      final polygon = Polygon(
        polygonId: polygonId,
        points: polygonPoints,
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.3),
      );
      polygons = {polygon};
    });
  }

  void _clearMarkersAndPolygon() {
    setState(() {
      markers.clear();
      polygons.clear();
      polygonPoints.clear();
      _calculateMetrics();
    });
  }
}

class KebunDataModel {
  final double perimeter;
  final double area;
  final List<LatLng> polygonPoints;

  KebunDataModel(this.perimeter, this.area, this.polygonPoints);
}