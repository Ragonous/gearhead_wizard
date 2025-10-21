class MainJournalMeasurement {
  String a;
  String b;

  MainJournalMeasurement({this.a = '', this.b = ''});

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
    };
  }

  factory MainJournalMeasurement.fromJson(Map<String, dynamic> json) {
    return MainJournalMeasurement(
      a: json['a'] as String,
      b: json['b'] as String,
    );
  }
}