// A simple class to hold measurements for one piston
class PistonMeasurement {
  String a; // Piston Diameter A
  String b; // Piston Diameter B
  String pinBoreA; // Pin Bore Diameter A
  String pinBoreB; // Pin Bore Diameter B
  String wristPinOd; // Wrist Pin Outer Diameter

  PistonMeasurement({
    this.a = '',
    this.b = '',
    this.pinBoreA = '',
    this.pinBoreB = '',
    this.wristPinOd = '',
  });

  // Converts our object into a Map (which can be saved as JSON)
  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
      'pinBoreA': pinBoreA,
      'pinBoreB': pinBoreB,
      'wristPinOd': wristPinOd,
    };
  }

  // Creates an object from a Map (which we load from JSON)
  factory PistonMeasurement.fromJson(Map<String, dynamic> json) {
    return PistonMeasurement(
      a: json['a'] as String? ?? '', // Use ?? '' for safety on load
      b: json['b'] as String? ?? '',
      pinBoreA: json['pinBoreA'] as String? ?? '',
      pinBoreB: json['pinBoreB'] as String? ?? '',
      wristPinOd: json['wristPinOd'] as String? ?? '',
    );
  }
}