import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_app_assessment/controllers/trip_controller.dart';

class TripSummary extends StatelessWidget {
  TripSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TripController>(builder: (controller) {
      final trip = controller.trip.value;
      print(trip.toJson());
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height / 2.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trip Summary", style: TextStyle(fontSize: 20)),
                Text("${trip.distance} km",
                    style: const TextStyle(fontSize: 20)),
              ],
            ),
            Divider(color: Theme.of(context).primaryColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trip.fromSource!),
                const Spacer(),
                const Icon(Icons.keyboard_double_arrow_right_rounded),
                const Icon(Icons.keyboard_double_arrow_right_rounded),
                const Spacer(),
                Text(trip.toDestination!),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                trip.destination!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trip.startTime!),
                const Text("arrival at"),
                Text(trip.endTime!),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${trip.duration} mins",
                    style: const TextStyle(fontSize: 18)),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "${trip.price!.toStringAsFixed(0)} AED",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.cancelTrip();
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.calculateTripDetails();
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
                  child: const Text("Confirm",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
