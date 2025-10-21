// A simple class to hold the A and B measurement strings for one piston
class PistonMeasurement {
  String a;
  String b;

  PistonMeasurement({this.a = '', this.b = ''});

  // Converts our object into a Map (which can be saved as JSON)
  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  // Creates an object from a Map (which we load from JSON)
  factory PistonMeasurement.fromJson(Map<String, dynamic> json) {
    return PistonMeasurement(
      a: json['a'] as String,
      b: json['b'] as String,
    );
  }
}