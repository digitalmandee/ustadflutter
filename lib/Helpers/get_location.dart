import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Position?> getCurrentLocation() async {
  var status = await Permission.locationWhenInUse.request();
  if (status.isGranted) {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  } else {
    debugPrint("Location permission not granted.");
    return null;
  }
}
