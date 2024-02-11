class Trip {
  String? startTime;
  String? endTime;
  String? destination;
  String? fromSource;
  String? toDestination;
  int? duration;
  int? distance;
  double? price;

  Trip(
      {this.startTime,
      this.endTime,
      this.destination,
      this.fromSource,
      this.toDestination,
      this.duration,
      this.distance,
      this.price});

  Trip.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    destination = json['destination'];
    fromSource = json['fromSource'];
    toDestination = json['toDestination'];
    duration = json['duration'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['destination'] = this.destination;
    data['fromSource'] = this.fromSource;
    data['toDestination'] = this.toDestination;
    data['duration'] = this.duration;
    data['price'] = this.price;
    return data;
  }
}
