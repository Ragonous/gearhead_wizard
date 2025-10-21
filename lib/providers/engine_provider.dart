import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearhead_wizard/models/main_bore_measurement.dart';
import 'package:gearhead_wizard/models/cylinder_bore_measurement.dart';

class EngineProvider extends ChangeNotifier {
  // --- 1. INTERNAL DATA ---
  int _numMainBores = 5;
  int _numCylinders = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;

  String _mainMin = '';
  String _mainMax = '';
  String _cylMin = '';
  String _cylMax = '';

  // Two separate lists for data
  List<MainBoreMeasurement> _mainMeasurements = [];
  List<CylinderBoreMeasurement> _cylMeasurements = [];

  // Result lists
  final List<double?> _mainRoundness = [];
  final List<double?> _cylRoundness = [];
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _cylWithinA = [];
  final List<bool?> _cylWithinB = [];

  // --- 2. GETTERS ---
  int get numMainBores => _numMainBores;
  int get numCylinders => _numCylinders;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;

  String get mainMin => _mainMin;
  String get mainMax => _mainMax;
  String get cylMin => _cylMin;
  String get cylMax => _cylMax;

  List<MainBoreMeasurement> get mainMeasurements => _mainMeasurements;
  List<CylinderBoreMeasurement> get cylMeasurements => _cylMeasurements;

  List<double?> get mainRoundness => _mainRoundness;
  List<double?> get cylRoundness => _cylRoundness;
  List<bool?> get mainWithinA => _mainWithinA;
  List<bool?> get mainWithinB => _mainWithinB;
  List<bool?> get cylWithinA => _cylWithinA;
  List<bool?> get cylWithinB => _cylWithinB;

  // --- 3. METHODS ---
  void setNumMainBores(int n) {
    _numMainBores = n.clamp(1, 10);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  void setNumCylinders(int n) {
    _numCylinders = n.clamp(1, 16);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  // Measurement text updates
  void updateMainA(int index, String value) {
    if (index < _mainMeasurements.length) _mainMeasurements[index].a = value;
  }
  void updateMainB(int index, String value) {
    if (index < _mainMeasurements.length) _mainMeasurements[index].b = value;
  }
  void updateCylA(int index, String value) {
    if (index < _cylMeasurements.length) _cylMeasurements[index].a = value;
  }
  void updateCylB(int index, String value) {
    if (index < _cylMeasurements.length) _cylMeasurements[index].b = value;
  }

  // Limit text updates
  void updateMainMin(String value) => _mainMin = value;
  void updateMainMax(String value) => _mainMax = value;
  void updateCylMin(String value) => _cylMin = value;
  void updateCylMax(String value) => _cylMax = value;

  // Toggle updates
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

  // --- 4. CALCULATION ---
  void calculate() {
    _clearResults();

    final mainMinVal = _limitsEnabled ? _p(_mainMin) : null;
    final mainMaxVal = _limitsEnabled ? _p(_mainMax) : null;
    final cylMinVal = _limitsEnabled ? _p(_cylMin) : null;
    final cylMaxVal = _limitsEnabled ? _p(_cylMax) : null;

    // Calculate Mains
    for (int i = 0; i < _numMainBores; i++) {
      final a = _p(_mainMeasurements[i].a);
      final b = _p(_mainMeasurements[i].b);
      if (_crossSections) {
        _mainRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
      }
      if (_limitsEnabled) {
        _mainWithinA[i] = _within(a, mainMinVal, mainMaxVal);
        if (_crossSections) {
          _mainWithinB[i] = _within(b, mainMinVal, mainMaxVal);
        }
      }
    }

    // Calculate Cylinders
    for (int i = 0; i < _numCylinders; i++) {
      final a = _p(_cylMeasurements[i].a);
      final b = _p(_cylMeasurements[i].b);
      if (_crossSections) {
        _cylRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
      }
      if (_limitsEnabled) {
        _cylWithinA[i] = _within(a, cylMinVal, cylMaxVal);
        if (_crossSections) {
          _cylWithinB[i] = _within(b, cylMinVal, cylMaxVal);
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
    for (int i = 0; i < _mainRoundness.length; i++) {
      _mainRoundness[i] = null;
      _mainWithinA[i] = null;
      _mainWithinB[i] = null;
    }
    for (int i = 0; i < _cylRoundness.length; i++) {
      _cylRoundness[i] = null;
      _cylWithinA[i] = null;
      _cylWithinB[i] = null;
    }
  }

  // --- 5. LIST RESIZING ---
  void _resizeLists() {
    // Helper for resizing any list
    void resizeList(List<dynamic> list, int targetSize) {
      while (list.length < targetSize) list.add(null);
      while (list.length > targetSize) list.removeLast();
    }
    
    // Resize data lists
    while (_mainMeasurements.length < _numMainBores) {
      _mainMeasurements.add(MainBoreMeasurement());
    }
    while (_mainMeasurements.length > _numMainBores) {
      _mainMeasurements.removeLast();
    }
    
    while (_cylMeasurements.length < _numCylinders) {
      _cylMeasurements.add(CylinderBoreMeasurement());
    }
    while (_cylMeasurements.length > _numCylinders) {
      _cylMeasurements.removeLast();
    }

    // Resize result lists
    resizeList(_mainRoundness, _numMainBores);
    resizeList(_mainWithinA, _numMainBores);
    resizeList(_mainWithinB, _numMainBores);
    
    resizeList(_cylRoundness, _numCylinders);
    resizeList(_cylWithinA, _numCylinders);
    resizeList(_cylWithinB, _numCylinders);
  }

  // --- 6. SAVE & LOAD ---
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save simple values
    prefs.setInt('engine_numMainBores', _numMainBores);
    prefs.setInt('engine_numCylinders', _numCylinders);
    prefs.setBool('engine_crossSections', _crossSections);
    prefs.setBool('engine_limitsEnabled', _limitsEnabled);
    prefs.setString('engine_mainMin', _mainMin);
    prefs.setString('engine_mainMax', _mainMax);
    prefs.setString('engine_cylMin', _cylMin);
    prefs.setString('engine_cylMax', _cylMax);
    
    // Save Main list as JSON
    List<Map<String, dynamic>> mainJsonList = 
        _mainMeasurements.map((p) => p.toJson()).toList();
    prefs.setString('engine_mainMeasurements', jsonEncode(mainJsonList));
    
    // Save Cylinder list as JSON
    List<Map<String, dynamic>> cylJsonList = 
        _cylMeasurements.map((p) => p.toJson()).toList();
    prefs.setString('engine_cylMeasurements', jsonEncode(cylJsonList));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load simple values
    _numMainBores = prefs.getInt('engine_numMainBores') ?? 5;
    _numCylinders = prefs.getInt('engine_numCylinders') ?? 8;
    _crossSections = prefs.getBool('engine_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('engine_limitsEnabled') ?? false;
    _mainMin = prefs.getString('engine_mainMin') ?? '';
    _mainMax = prefs.getString('engine_mainMax') ?? '';
    _cylMin = prefs.getString('engine_cylMin') ?? '';
    _cylMax = prefs.getString('engine_cylMax') ?? '';

    // Load Main list
    try {
      final String? jsonString = prefs.getString('engine_mainMeasurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _mainMeasurements = jsonList
            .map((jsonItem) => MainBoreMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _mainMeasurements = [];
    }
    
    // Load Cylinder list
    try {
      final String? jsonString = prefs.getString('engine_cylMeasurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _cylMeasurements = jsonList
            .map((jsonItem) => CylinderBoreMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _cylMeasurements = [];
    }

    _resizeLists();
  }
}