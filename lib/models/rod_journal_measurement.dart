class RodJournalMeasurement {
  String a;
  String b;

  RodJournalMeasurement({this.a = '', this.b = ''});

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  factory RodJournalMeasurement.fromJson(Map<String, dynamic> json) {
    return RodJournalMeasurement(
      a: json['a'] as String,
      b: json['b'] as String,
    );
  }
}