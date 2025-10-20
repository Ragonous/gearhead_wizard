import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearhead_wizard/models/piston_measurement.dart';

class PistonProvider extends ChangeNotifier {
  int _numPistons = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;

  String _min = '';
  String _max = '';

  List<PistonMeasurement> _measurements = [];
  List<double?> _roundness = [];
  List<bool?> _withinA = [];
  List<bool?> _withinB = [];

  int get numPistons => _numPistons;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;
  String get min => _min;
  String get max => _max;
  List<PistonMeasurement> get measurements => _measurements;
  List<double?> get roundness => _roundness;
  List<bool?> get withinA => _withinA;
  List<bool?> get withinB => _withinB;

  void setNumPistons(int n) {
    _numPistons = n.clamp(1, 16);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  void updateMeasurementA(int index, String value) {
    if (index < _measurements.length) {
      _measurements[index].a = value;
    }
  }

  void updateMeasurementB(int index, String value) {
    if (index < _measurements.length) {
      _measurements[index].b = value;
    }
  }

  void updateMin(String value) {
    _min = value;
  }
  void updateMax(String value) {
    _max = value;
  }

  void setCrossSections(bool value) {
    _crossSections = value;
    _clearResults();
    notifyListeners();
    saveData();
  }

  void setLimitsEnabled(bool value) {
    _limitsEnabled = value;
    _clearResults();
    notifyListeners();
    saveData();
  }

  void calculate() {
    _clearResults();
    final minVal = _limitsEnabled ? _p(_min) : null;
    final maxVal = _limitsEnabled ? _p(_max) : null;

    for (int i = 0; i < _numPistons; i++) {
      final a = _p(_measurements[i].a);
      final b = _p(_measurements[i].b);

      if (_crossSections) {
        _roundness[i] = (a != null && b != null) ? (a - b).abs() : null;
      }
      if (_limitsEnabled) {
        _withinA[i] = _within(a, minVal, maxVal);
        if (_crossSections) {
          _withinB[i] = _within(b, minVal, maxVal);
        }
      }
    }
    notifyListeners();
    saveData();
  }

  double? _p(String s) => double.tryParse(s.trim());

  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }

  void _clearResults() {
    for (int i = 0; i < _numPistons; i++) {
      _roundness[i] = null;
      _withinA[i] = null;
      _withinB[i] = null;
    }
  }

  void _resizeLists() {
    while (_measurements.length < _numPistons) {
      _measurements.add(PistonMeasurement());
    }
    while (_measurements.length > _numPistons) {
      _measurements.removeLast();
    }
    while (_roundness.length < _numPistons) {
      _roundness.add(null);
    }
    while (_roundness.length > _numPistons) {
      _roundness.removeLast();
    }
    while (_withinA.length < _numPistons) {
      _withinA.add(null);
    }
    while (_withinA.length > _numPistons) {
      _withinA.removeLast();
    }
    while (_withinB.length < _numPistons) {
      _withinB.add(null);
    }
    while (_withinB.length > _numPistons) {
      _withinB.removeLast();
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setInt('piston_numPistons', _numPistons);
    prefs.setBool('piston_crossSections', _crossSections);
    prefs.setBool('piston_limitsEnabled', _limitsEnabled);
    prefs.setString('piston_min', _min);
    prefs.setString('piston_max', _max);
    
    List<Map<String, dynamic>> jsonList = 
        _measurements.map((p) => p.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    prefs.setString('piston_measurements', jsonString);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _numPistons = prefs.getInt('piston_numPistons') ?? 8;
    _crossSections = prefs.getBool('piston_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('piston_limitsEnabled') ?? false;
    _min = prefs.getString('piston_min') ?? '';
    _max = prefs.getString('piston_max') ?? '';

    try {
      final String? jsonString = prefs.getString('piston_measurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _measurements = jsonList
            .map((jsonItem) => PistonMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _measurements = [];
    }
    _resizeLists();
  }
}