import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_map/service/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapHomeScreen extends StatefulWidget {
  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  GoogleMapController? _mapController;
  Marker? _marker;
  List<LatLng> polylinePoints = [];
  Polyline? _polyline;
  Timer? updateTimer;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();

    updateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateLocation(),
    );
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Permission check + current location ek jaygay handle
      Position position = await LocationService.getCurrentLocation();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _marker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: currentLatLng,
          infoWindow: InfoWindow(
            title: "My current location",
            snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
          ),
        );

        polylinePoints = [currentLatLng];
        _updatePolyline();
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    } catch (e) {
      debugPrint("Init location failed: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location পাওয়া যায়নি, permission/ GPS টা check করে নাও।",
          ),
        ),
      );
    }
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      LatLng newLoc = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _marker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: newLoc,
          infoWindow: InfoWindow(
            title: "My current location",
            snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
          ),
        );

        polylinePoints.add(newLoc);
        _updatePolyline();
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(newLoc));
    } catch (e) {
      debugPrint("Update location failed: $e");
    }
  }

  void _updatePolyline() {
    _polyline = Polyline(
      polylineId: const PolylineId("trackingPolyline"),
      points: polylinePoints,
      width: 5,
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Location Tracking")),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: _marker != null ? {_marker!} : {},
        polylines: _polyline != null ? {_polyline!} : {},
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
          _initializeLocation();
        },
      ),
    );
  }
}
