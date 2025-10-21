class CamshaftJournalMeasurement {
  String a;
  String b;

  CamshaftJournalMeasurement({this.a = '', this.b = ''});

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  factory CamshaftJournalMeasurement.fromJson(Map<String, dynamic> json) {
    return CamshaftJournalMeasurement(
      a: json['a'] as String? ?? '',
      b: json['b'] as String? ?? '',
    );
  }
}