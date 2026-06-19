import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/constants.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TrackOrder extends StatefulWidget {
  const TrackOrder({
    super.key,
    required this.product,
  });
  final ProductModel product;
  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  List<LatLng> coordinates = [];
  final LatLng destination = const LatLng(37.7645, -122.43994);
  final LatLng source = const LatLng(37.7667, -122.4444);
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPolylines();
  }

  void getPolylines() async {
    try {
      final currentPosition =
          context.read<GetPermissionLocation>().currentPosition;

      PolylinePoints points = PolylinePoints();
      PolylineResult result = await points.getRouteBetweenCoordinates(
        request: PolylineRequest(
          mode: TravelMode.driving,
          origin: PointLatLng(source.latitude, source.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
        ),
      );
      log('Polyline result: $result');

      if (result.points.isNotEmpty) {
        coordinates =
            result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
        setState(() {});
      } else {
        log('No points found in the result.');
        //   }
        // } else {
        //   log('Current position is null.');
      }
    } catch (e) {
      log('Error fetching polylines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition =
        context.watch<GetPermissionLocation>().currentPosition;
    print(currentPosition);
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            double.parse(source.latitude.toString()),
            double.parse(
              source.longitude.toString(),
            ),
          ),
          zoom: 12,
        ),
        polylines: {
          Polyline(
              polylineId: const PolylineId('route'),
              points: coordinates,
              width: 10,
              color: Colors.red),
        },
        markers: {
          Marker(
            markerId: const MarkerId('currentPosition'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                .hueOrange), // Change the hue to blue or any other color you prefer
            position: LatLng(
              double.parse(destination.latitude.toString()),
              double.parse(destination.longitude.toString()),
            ),
            infoWindow: const InfoWindow(
              title: 'My Location',
            ),
          ),
          Marker(
            markerId: const MarkerId('destinationPostion'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                .hueRed), // Change the hue to blue or any other color you prefer
            position: LatLng(
              double.parse(source.latitude.toString()),
              double.parse(source.longitude.toString()),
            ),
            infoWindow: const InfoWindow(
              title: 'My Location',
            ),
          ),
        },
      ),
    );
  }
}
