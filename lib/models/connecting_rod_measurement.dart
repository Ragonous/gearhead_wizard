// A simple class to hold the A/B measurements for both ends of a rod
class ConnectingRodMeasurement {
  String bigA;
  String bigB;
  String pinA;
  String pinB;

  ConnectingRodMeasurement({
    this.bigA = '',
    this.bigB = '',
    this.pinA = '',
    this.pinB = '',
  });

  // Converts our object into a Map (which can be saved as JSON)
  Map<String, dynamic> toJson() {
    return {
      'bigA': bigA,
      'bigB': bigB,
      'pinA': pinA,
      'pinB': pinB,
    };
  }

  // Creates an object from a Map (which we load from JSON)
  factory ConnectingRodMeasurement.fromJson(Map<String, dynamic> json) {
    return ConnectingRodMeasurement(
      bigA: json['bigA'] as String,
      bigB: json['bigB'] as String,
      pinA: json['pinA'] as String,
      pinB: json['pinB'] as String,
    );
  }
}