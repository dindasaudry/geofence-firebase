import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonLiveTracking extends StatefulWidget {
  @override
  _PolygonLiveTrackingState createState() => _PolygonLiveTrackingState();
}

class _PolygonLiveTrackingState extends State<PolygonLiveTracking> {
  Completer<GoogleMapController> mapController = Completer();
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  Set<Polyline> polylines = {};
  List<LatLng> polygonPoints = [];
  List<LatLng> polylineCoordinates = [];
  double _totalDistance = 0;
  double _area = 0;
  double _perimeter = 0;
  Position? _currentPosition;
  bool _ukur = false;
  void startMeasurement() {
    setState(() {
      _startTracking();
    });
    print('Mulai pengukuran');
  }

  void stopMeasurement() {
    setState(() {
      stopLocationTracking();
    });
    print('Selesai pengukuran');
  }

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
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
        titleSpacing: 0,
        shadowColor: Colors.black,
        toolbarHeight: 40,
        elevation: 1,
        title: Text(
          'Ukur Lahan',
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 17.35,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context,
                    {"PolygonsCoordinate": polygonPoints, "LuasKebun": _area});
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
              icon: const Icon(
                CupertinoIcons.trash,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Kebun Ini Milik Pak ___',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16.1,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Container(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Keliling: ${_formatDistance(_perimeter)}',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16.1,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  'Luas: ${_formatArea(_area)}',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16.1,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          if (_currentPosition != null)
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 18,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.hybrid,
                markers: markers,
                polygons: polygons,
                polylines: polylines,
                onTap: _addMarkerAndPolygonPoint,
              ),
            ),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      _ukur = !_ukur;
                      if (_ukur) {
                        startMeasurement();
                      } else {
                        stopMeasurement();
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        _ukur
                            ? CupertinoIcons.pause
                            : CupertinoIcons.play_arrow,
                      ),
                      Text(
                        _ukur ? 'Selesai Pengukuran' : 'Mulai Pengukuran',
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12.35,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _addMaker,
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.placemark),
                      Text(
                        'Tambah Tanda',
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12.35,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _createPolygon();
                  },
                  child: Column(
                    children: [
                      const Icon(CupertinoIcons.checkmark),
                      Text(
                        'Selesai',
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12.35,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _addMarkerAndPolygonPoint(LatLng point) {
    setState(() {
      // Menambahkan marker pada titik yang ditekan untuk koordinat polygon
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
      // _calculateMetrics();
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

      if (polygonPoints.length > 2) {
        _updatePolygon();
      }
      // _calculateMetrics();
    });
  }

  void _updatePolygon() {
    setState(() {
      const polygonId = PolygonId('polygon');
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
      polylineCoordinates.clear();
      _calculateMetrics();
    });
  }

  void _addMaker() {
    _addMarkerAndPolygonPoint(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
  }

  void _startTracking() {
 final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
 );

 Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
    setState(() {
      polylineCoordinates.add(LatLng(
        position.latitude,
        position.longitude,
      ));

      polylines.add(Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.red,
        width: 5,
        points: polylineCoordinates,
      ));
    });
 });
}


  void _createPolygon() {
    if (polylineCoordinates.length >= 3) {
      final List<LatLng> polygonPoints = List.from(polylineCoordinates);

      final PolygonId polygonId = PolygonId("polygon");
      final Polygon polygon = Polygon(
        polygonId: polygonId,
        points: polygonPoints,
        strokeWidth: 10,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.3),
      );

      setState(() {
        polygons = {polygon};
      });
    }
  }

  void stopLocationTracking() {
    setState(() {
      _calculateMetrics();
      _createPolygon();
    });
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
    }
  }
}

double calculateDistance(LatLng p1, LatLng p2) {
  const double earthRadius = 6371.0; // Radius of the Earth in kilometers
  final double lat1 = degreesToRadians(p1.latitude);
  final double lon1 = degreesToRadians(p1.longitude);
  final double lat2 = degreesToRadians(p2.latitude);
  final double lon2 = degreesToRadians(p2.longitude);

  final double dLat = lat2 - lat1;
  final double dLon = lon2 - lon1;

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distance = earthRadius * c;

  return distance * 1000; // Mengonversi ke meter
}

double degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}