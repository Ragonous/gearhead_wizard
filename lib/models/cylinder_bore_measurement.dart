class CylinderBoreMeasurement {
  String a;
  String b;

  CylinderBoreMeasurement({this.a = '', this.b = ''});

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  factory CylinderBoreMeasurement.fromJson(Map<String, dynamic> json) {
    return CylinderBoreMeasurement(
      a: json['a'] as String,
      b: json['b'] as String,
    );
  }
}