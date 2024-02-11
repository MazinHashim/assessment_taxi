import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app_assessment/controllers/trip_controller.dart';

class RoutingWidget extends StatelessWidget {
  RoutingWidget({
    super.key,
  });

  final tripController = Get.put(TripController());

  @override
  Widget build(BuildContext context) {
    final markerSet = tripController.markerSet;

    return tripController.chooseFromMap.value
        ? Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              leading: TextButton(
                  onPressed: () {
                    tripController.cancelTrip();
                  },
                  child: const Text("Cancel")),
              contentPadding: EdgeInsets.zero,
              trailing: markerSet.length == 3
                  ? TextButton(
                      onPressed: () {
                        tripController.changeChooseFromMap();
                        tripController.calculateTripDetails();
                        tripController.getPolyline();
                      },
                      child: const Text("OK"))
                  : null,
              title: const Text(
                "Choose on map",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Wrap(
                children: [
                  const Text("Long press on map to select "),
                  Text(
                    markerSet.length == 1 ? "source" : "destination",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          )
        : tripController.isTripDetermined
            ? Container()
            : Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 3.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (from) async {
                        final placemark = await GeocodingPlatform.instance
                            .locationFromAddress(from)
                            .onError((error, stackTrace) => []);
                        if (placemark.isNotEmpty) {
                          tripController.setFrom(LatLng(
                              placemark.first.latitude,
                              placemark.first.longitude));
                        } else {
                          tripController.setFrom(const LatLng(0, 0));
                        }
                        print(tripController.fromSource.value.latitude);
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "From Source",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        suffixIcon: Icon(
                          tripController.fromSource.value.latitude == 0
                              ? Icons.keyboard_double_arrow_down_rounded
                              : Icons.check_box,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (to) async {
                        final placemark = await GeocodingPlatform.instance
                            .locationFromAddress(to)
                            .onError((error, stackTrace) => []);
                        if (placemark.isNotEmpty) {
                          final point = LatLng(placemark.first.latitude,
                              placemark.first.longitude);
                          tripController.setTo(point);
                        } else {
                          tripController.setTo(const LatLng(0, 0));
                        }
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: Icon(
                            tripController.toDest.value.latitude == 0
                                ? Icons.keyboard_double_arrow_up_rounded
                                : Icons.check_box,
                            color: Colors.white,
                          ),
                          hintStyle: const TextStyle(color: Colors.white),
                          hintText: "To Destination"),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            tripController.changeChooseFromMap();
                          },
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.map_rounded,
                          ),
                          label: const Text("Choose from map"),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: !tripController.isSourceAndDestFound
                              ? null
                              : () {
                                  tripController.addToMarkersSet(
                                      tripController.fromSource.value);
                                  tripController.addToMarkersSet(
                                      tripController.toDest.value);
                                  tripController.calculateTripDetails();
                                  tripController.getPolyline();
                                },
                          icon: const Icon(
                            Icons.directions,
                          ),
                          label: const Text("Go"),
                        ),
                      ],
                    )
                  ],
                ),
              );
  }
}
