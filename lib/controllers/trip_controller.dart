import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app_assessment/models/trip.dart';

class TripController extends GetxController {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Rx<LatLng> currentPosition = const LatLng(0, 0).obs;
  Rx<LatLng> fromSource = const LatLng(0, 0).obs;
  Rx<LatLng> toDest = const LatLng(0, 0).obs;
  final RxSet<Marker> _markerSet = const <Marker>{}.obs;
  final RxMap<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{}.obs;
  Rx<Trip> trip = Trip().obs;
  String? googleAPiKey = FlutterConfig.get('MY_API_KEY');
  bool? paidDirectionApi = bool.tryParse(
      FlutterConfig.get("PAID_DIRECTION_API")!,
      caseSensitive: false);
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];

  Set<Marker> get markerSet => _markerSet;
  Map<PolylineId, Polyline> get polylines => _polylines;
  RxBool locationServiceEnabled = false.obs;
  RxBool chooseFromMap = false.obs;
  RxBool toggle = true.obs;
  RxBool isLoading = false.obs;
  bool get isTripDetermined => markerSet.length > 1 && !chooseFromMap.value;
  Completer<GoogleMapController> get controller => _controller;
  bool get isSourceAndDestFound =>
      fromSource.value.latitude != 0 && toDest.value.latitude != 0;

  void setFrom(LatLng latLng) {
    fromSource.value = latLng;
    update();
  }

  void setTo(LatLng latLng) {
    toDest.value = latLng;
    update();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurple,
      points: polylineCoordinates,
      width: 2,
    );
    polylines[id] = polyline;
    update();
  }

  Future<void> getPolyline() async {
    if (paidDirectionApi == null || !paidDirectionApi!) {
      polylineCoordinates
          .add(LatLng(fromSource.value.latitude, fromSource.value.longitude));
      polylineCoordinates
          .add(LatLng(toDest.value.latitude, toDest.value.longitude));
    } else {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey!,
        PointLatLng(fromSource.value.latitude, fromSource.value.longitude),
        PointLatLng(toDest.value.latitude, toDest.value.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        for (PointLatLng point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
    }
    _addPolyLine();
  }

  Future<void> animateCameraPosition(Completer<GoogleMapController> ccontroller,
      CameraPosition cameraPosition) async {
    isLoading.value = true;
    final GoogleMapController controller = await ccontroller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    isLoading.value = false;
    update();
  }

  Future<void> calculateTripDetails() async {
    DateTime startTime = DateTime.now();
    final distance = Geolocator.distanceBetween(
      fromSource.value.latitude,
      fromSource.value.longitude,
      toDest.value.latitude,
      toDest.value.longitude,
    );
    final fromPlacemark = await placemarkFromCoordinates(
      fromSource.value.latitude,
      fromSource.value.longitude,
    );
    final toPlacemark = await placemarkFromCoordinates(
      toDest.value.latitude,
      toDest.value.longitude,
    );
    // Dio dio = Dio();
    // Response response = await dio.get(
    //     "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=${dotenv.env['MY_API_KEY']}");
    DateTime endTime = DateTime.now().add(const Duration(minutes: 23));
    final duration = Duration(minutes: endTime.difference(startTime).inMinutes);
    trip.value = Trip(
      startTime: "${startTime.hour}:${startTime.minute}",
      endTime: "${endTime.hour}:${endTime.minute}",
      distance: (distance / 1000).round(),
      fromSource: fromPlacemark.first.subLocality,
      toDestination: toPlacemark.first.subLocality,
      destination: toPlacemark.first.street!
          .substring(1, toPlacemark.first.street!.lastIndexOf("-")),
      price: (distance / 1000).round() * 2,
      duration: duration.inMinutes,
    );
    double zoom = calculateZoom();
    animateCameraPosition(
        _controller, CameraPosition(zoom: zoom, target: toDest.value));
    update();
  }

  double calculateZoom() {
    double zoom = 15;
    if (trip.value.distance! < 5) {
      zoom = 17;
    } else if (trip.value.distance! >= 5 && trip.value.distance! < 10) {
      zoom = 16;
    } else if (trip.value.distance! >= 10 && trip.value.distance! < 20) {
      zoom = 15;
    } else if (trip.value.distance! >= 20 && trip.value.distance! < 30) {
      zoom = 14;
    }
    return zoom;
  }

  /// fetch current location of the device
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    isLoading.value = true;

    serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        return Future.error('Location services are disabled.');
      },
    );
    locationServiceEnabled.value = serviceEnabled;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Permissions are permanently denied, we cannot request permissions.',
      );
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentPosition.value = LatLng(position.latitude, position.longitude);
    const imgsrc = 'assets/imgs/current_location.png';
    final markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      imgsrc,
    );
    isLoading.value = false;
    _markerSet
        .removeWhere((marker) => marker.markerId.value == "current-location");
    markerSet.add(Marker(
      markerId: const MarkerId("current-location"),
      icon: markerbitmap,
      position: currentPosition.value,
    ));
    update();
  }

  void cancelTrip() {
    chooseFromMap.value = false;
    fromSource.value = const LatLng(0, 0);
    toDest.value = const LatLng(0, 0);
    _polylines.clear();
    polylineCoordinates.clear();
    _markerSet
        .removeWhere((marker) => marker.markerId.value.startsWith("mark"));
    update();
  }

  void changeChooseFromMap() {
    chooseFromMap.value = !chooseFromMap.value;
    if (!chooseFromMap.value && markerSet.length != 3) {
      _markerSet
          .removeWhere((marker) => marker.markerId.value.startsWith("mark"));
    }

    update();
  }

  void addToMarkersSet(LatLng latLng) {
    _markerSet.removeWhere(
        (marker) => marker.markerId.value == "mark-${toggle.value}");
    _markerSet.add(Marker(
      markerId: MarkerId("mark-${toggle.value}"),
      position: latLng,
    ));
    toggle.value = !toggle.value;
    update();
  }
}
