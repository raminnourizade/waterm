import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("سرویس موقعیت‌یاب غیرفعال است.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("اجازه دسترسی به موقعیت مکانی داده نشد.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("اجازه موقعیت‌یابی برای همیشه رد شده است.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _marker = Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLatLng!,
        infoWindow: const InfoWindow(title: 'موقعیت فعلی'),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نقشه')),
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng!,
          zoom: 16,
        ),
        myLocationEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _marker != null ? {_marker!} : {},
      ),
    );
  }
}
