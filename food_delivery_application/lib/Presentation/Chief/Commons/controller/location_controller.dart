import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetPermissionLocation extends ChangeNotifier {
  LatLng? currentPosition;
  String? currentDistrict;

  Future<void> getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double long = position.longitude;
      log(lat.toString());
      log(long.toString());
      currentPosition = LatLng(lat, long);
      notifyListeners();
      log(currentPosition.toString());
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      notifyListeners();
      log(placemark.toString());
      Placemark place = placemark[0];
      String city = place.locality ?? place.subLocality ?? '';
      String province = place.administrativeArea ?? '';
      
      if (city.isNotEmpty && province.isNotEmpty) {
        currentDistrict = "$city, $province";
      } else {
        currentDistrict = city.isNotEmpty ? city : province;
      }
      notifyListeners();
    }
  }
}
