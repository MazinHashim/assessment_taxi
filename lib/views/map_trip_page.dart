import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app_assessment/controllers/trip_controller.dart';
import 'package:taxi_app_assessment/views/widgets/rounting_widget.dart';
import 'package:taxi_app_assessment/views/widgets/trip_summary.dart';

class MapTripPage extends StatefulWidget {
  const MapTripPage({super.key});

  @override
  State<MapTripPage> createState() => _MapTripPageState();
}

class _MapTripPageState extends State<MapTripPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final tripController = Get.put(TripController());

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    await tripController.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<TripController>(builder: (controller) {
        final latLng = controller.currentPosition.value;
        final serviceEnabled = controller.locationServiceEnabled.value;
        final markerSet = controller.markerSet;
        final polylines = controller.polylines;
        final chooseFromMap = tripController.chooseFromMap.value;

        return Stack(
          children: [
            latLng.latitude == 0
                ? const Center(child: Text("Finding location..."))
                : GoogleMap(
                    onLongPress: !chooseFromMap
                        ? null
                        : (point) {
                            if (tripController.toggle.value) {
                              tripController.setFrom(point);
                            } else {
                              tripController.setTo(point);
                            }
                            tripController.addToMarkersSet(point);
                          },
                    markers: markerSet,
                    polylines: Set<Polyline>.of(polylines.values),
                    initialCameraPosition: CameraPosition(
                      target: latLng,
                      zoom: 16,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
            RoutingWidget(),
            if (tripController.isTripDetermined)
              Positioned(
                bottom: 30,
                right: 30,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (contxt) {
                          return TripSummary();
                        });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).primaryColor,
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text("Trip Summary",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            Positioned(
              bottom: 30,
              left: 30,
              child: IconButton(
                onPressed: () async {
                  await tripController
                      .getCurrentLocation()
                      .onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(error.toString()),
                      backgroundColor: Theme.of(context).primaryColor,
                    ));
                  }).then((value) {
                    final latLng = tripController.currentPosition.value;

                    _animateCameraPosition(CameraPosition(
                        zoom: 18,
                        target: LatLng(latLng.latitude, latLng.longitude)));
                  });
                },
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                icon: Icon(
                  !serviceEnabled ? Icons.gps_off : Icons.gps_fixed,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _animateCameraPosition(CameraPosition position) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
