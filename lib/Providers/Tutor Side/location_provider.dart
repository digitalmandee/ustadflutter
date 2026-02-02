import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class LocationModel {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  double? distanceFromUser; // miles

  LocationModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceFromUser,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class LocationProvider extends ChangeNotifier {
  final AppDio dio;
  List<LocationModel> _locations = [];

  List<LocationModel> get locations => _locations;

  double? userLatitude;
  double? userLongitude;

  LocationProvider(BuildContext context) : dio = AppDio(context);

  // ===================== Distance Calculation =====================
  double calculateDistanceMiles(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 3958.8; // miles
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // ===================== Set user location =====================
  void setUserLocation(double lat, double lon) {
    userLatitude = lat;
    userLongitude = lon;

    // Update all existing locations distance
    for (var loc in _locations) {
      loc.distanceFromUser =
          calculateDistanceMiles(lat, lon, loc.latitude, loc.longitude);
    }

    notifyListeners();
  }

  // ===================== Fetch locations =====================
  Future<void> fetchLocations() async {
    try {
      final res = await dio.get(path: AppUrls.getLocations);
      final List<dynamic> locationList = res.data['data'];
      _locations =
          locationList.map((json) => LocationModel.fromJson(json)).toList();

      // calculate distance if user location known
      if (userLatitude != null && userLongitude != null) {
        for (var loc in _locations) {
          loc.distanceFromUser = calculateDistanceMiles(
              userLatitude!, userLongitude!, loc.latitude, loc.longitude);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Locations Error: $e");
    }
  }

  // ===================== Add Location =====================
  Future<void> addLocation(String name) async {
    try {
      List<Location> geo = await locationFromAddress(name);
      if (geo.isEmpty) throw Exception("Coordinates not found");

      double lat = geo.first.latitude;
      double lng = geo.first.longitude;

      final res = await dio.post(path: AppUrls.addLocation, data: {
        "address": name,
        "latitude": lat.toString(),
        "longitude": lng.toString(),
      });

      final newLoc = LocationModel.fromJson(res.data['data']);

      // calculate distance
      if (userLatitude != null && userLongitude != null) {
        newLoc.distanceFromUser =
            calculateDistanceMiles(userLatitude!, userLongitude!, lat, lng);
      }

      _locations.add(newLoc);
      notifyListeners();
    } catch (e) {
      debugPrint("Add Location Error: $e");
    }
  }

  // ===================== Delete Location =====================
  Future<void> deleteLocation(String id) async {
    try {
      await dio.delete(path: "${AppUrls.deleteLocation}?locationId=$id");
      _locations.removeWhere((loc) => loc.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Location Error: $e");
    }
  }

  void clear() {
    _locations.clear();
    userLatitude = null;
    userLongitude = null;
    notifyListeners();
  }
}
