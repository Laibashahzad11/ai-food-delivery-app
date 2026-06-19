import 'dart:developer';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMapUI extends StatefulWidget {
  const GoogleMapUI({
    super.key,
    required this.keyword,
  });
  final String keyword;
  @override
  State<GoogleMapUI> createState() => _GoogleMapUIState();
}

class _GoogleMapUIState extends State<GoogleMapUI> {
  CustomInfoWindowController controller = CustomInfoWindowController();
  late GoogleMapController googlecontroller;
  static const LatLng loc = LatLng(37.4223, -10.0848);

  Future<double> calculateDistance(
      {required LatLng start, required LatLng end}) async {
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distanceInMeters;
  }

  @override
  void initState() {
    context.read<ProductController>().getSearchProducts(search: widget.keyword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition =
        context.watch<GetPermissionLocation>().currentPosition;
    log('location is ${currentPosition.toString()}');
    final count = context.watch<ProductController>();
    return Scaffold(
      appBar: AppBar(
        title: count.searchProductList.isNotEmpty
            ? Text('Findings ${count.searchProductList.length}')
            : const Text(''),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.orangeColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          // if (currentPosition != null) {
          log('kamal');
          await googlecontroller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                        double.parse(currentPosition!.latitude.toString()),
                        double.parse(currentPosition.longitude.toString())) ??
                    const LatLng(0.0, 0.0),
                zoom: 14.0,
              ),
            ),
          );
          // }
          // googlecontroller
          //     .animateCamera(CameraUpdate.newCameraPosition(_kGoogle));
        },
        child: const Icon(Icons.filter_center_focus),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          GoogleMap(
            onTap: (argument) {
              print(argument);
              controller.hideInfoWindow!();
            },
            initialCameraPosition:
                CameraPosition(target: currentPosition ?? loc, zoom: 13),
            markers: {
              // Marker for current position
              if (currentPosition != null)
                Marker(
                    markerId: const MarkerId('currentPosition'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                        .hueOrange), // Change the hue to blue or any other color you prefer
                    position: LatLng(
                      double.parse(currentPosition.latitude.toString()),
                      double.parse(currentPosition.longitude.toString()),
                    ),
                    infoWindow: const InfoWindow(
                      title: 'My Location',
                    ),
                    zIndex: 1),
              // Markers for products
              ...context.read<ProductController>().productList.map(
                (e) {
                  if (e.productName.contains(widget.keyword.toUpperCase())) {
                    log('object');
                    log(e.productName);

                    return Marker(
                      onTap: () async {
                        var distance = await calculateDistance(
                          start: currentPosition!,
                          end: LatLng(
                            e.location!.lat!.toDouble(),
                            e.location!.lon!.toDouble(),
                          ),
                        );
                        log(distance.toString());
                        String distanceText = distance < 1000
                            ? '${distance.toStringAsFixed(0)} meters'
                            : '${(distance / 1000).toStringAsFixed(2)} km';

                        log(distanceText.toString());
                        controller.addInfoWindow!(
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(e.productImage),
                                            fit: BoxFit.cover),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(e.productOwner),
                                      Text(distanceText),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            LatLng(e.location!.lat!.toDouble(),
                                e.location!.lon!.toDouble()));
                      },
                      markerId: MarkerId(e.productName),
                      icon: BitmapDescriptor.defaultMarker,
                      position: LatLng(
                        double.parse(e.location!.lat.toString()),
                        double.parse(
                          e.location!.lon.toString(),
                        ),
                      ),
                    );
                  } else {
                    return Marker(
                      visible: false,
                      markerId: MarkerId(e.productOwner),
                      icon: BitmapDescriptor.defaultMarker,
                      position: LatLng(
                        double.parse(e.location!.lat.toString()),
                        double.parse(
                          e.location!.lon.toString(),
                        ),
                      ),
                    );
                  }
                },
              ),
            },
            onMapCreated: (con) {
              controller.googleMapController = con;
              googlecontroller = con;
            },
          ),
          CustomInfoWindow(
            controller: controller,
            height: 150,
            width: 200,
            offset: 35,
          ),
        ],
      ),
    );
  }
}
