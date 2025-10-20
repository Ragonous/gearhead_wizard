class MainBoreMeasurement {
  String a;
  String b;

  MainBoreMeasurement({this.a = '', this.b = ''});

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  factory MainBoreMeasurement.fromJson(Map<String, dynamic> json) {
    return MainBoreMeasurement(
      a: json['a'] as String,
      b: json['b'] as String,
    );
  }
}