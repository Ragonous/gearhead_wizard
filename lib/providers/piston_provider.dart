import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/piston_measurement.dart';

class PistonProvider extends ChangeNotifier {
  // --- 1. INTERNAL DATA --- (Unchanged)
  int _numPistons = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;
  String _pistonMin = '';
  String _pistonMax = '';
  String _pinBoreMin = '';
  String _pinBoreMax = '';
  String _wristPinMin = '';
  String _wristPinMax = '';
  List<PistonMeasurement> _measurements = [];
  List<double?> _pistonRoundness = [];
  List<bool?> _pistonWithinA = [];
  List<bool?> _pistonWithinB = [];
  List<double?> _pinBoreRoundness = [];
  List<bool?> _pinBoreWithinA = [];
  List<bool?> _pinBoreWithinB = [];
  List<bool?> _wristPinWithin = [];
  List<double?> _pinClearance = [];

  // --- 2. GETTERS --- (Unchanged)
  int get numPistons => _numPistons;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;
  String get pistonMin => _pistonMin;
  String get pistonMax => _pistonMax;
  String get pinBoreMin => _pinBoreMin;
  String get pinBoreMax => _pinBoreMax;
  String get wristPinMin => _wristPinMin;
  String get wristPinMax => _wristPinMax;
  List<PistonMeasurement> get measurements => _measurements;
  List<double?> get pistonRoundness => _pistonRoundness;
  List<bool?> get pistonWithinA => _pistonWithinA;
  List<bool?> get pistonWithinB => _pistonWithinB;
  List<double?> get pinBoreRoundness => _pinBoreRoundness;
  List<bool?> get pinBoreWithinA => _pinBoreWithinA;
  List<bool?> get pinBoreWithinB => _pinBoreWithinB;
  List<bool?> get wristPinWithin => _wristPinWithin;
  List<double?> get pinClearance => _pinClearance;

  // --- 3. METHODS --- (Unchanged)
  void setNumPistons(int n) {
    _numPistons = n.clamp(1, 16);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }
  void updatePistonA(int index, String value) {
    if (index < _measurements.length) _measurements[index].a = value;
  }
  void updatePistonB(int index, String value) {
    if (index < _measurements.length) _measurements[index].b = value;
  }
  void updatePinBoreA(int index, String value) {
    if (index < _measurements.length) _measurements[index].pinBoreA = value;
  }
  void updatePinBoreB(int index, String value) {
    if (index < _measurements.length) _measurements[index].pinBoreB = value;
  }
  void updateWristPinOd(int index, String value) {
    if (index < _measurements.length) _measurements[index].wristPinOd = value;
  }
  void updatePistonMin(String value) => _pistonMin = value;
  void updatePistonMax(String value) => _pistonMax = value;
  void updatePinBoreMin(String value) => _pinBoreMin = value;
  void updatePinBoreMax(String value) => _pinBoreMax = value;
  void updateWristPinMin(String value) => _wristPinMin = value;
  void updateWristPinMax(String value) => _wristPinMax = value;
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

  // --- 4. CALCULATION LOGIC --- (SPLIT INTO TWO METHODS)

  // Calculates ONLY Piston Diameter specs
  void calculatePistonSpecs() {
    _clearPistonResults(); // Clear only piston results

    final pistonMinVal = _limitsEnabled ? _p(_pistonMin) : null;
    final pistonMaxVal = _limitsEnabled ? _p(_pistonMax) : null;

    for (int i = 0; i < _numPistons; i++) {
      final pA = _p(_measurements[i].a);
      final pB = _p(_measurements[i].b);

      if (_crossSections) {
        _pistonRoundness[i] = (pA != null && pB != null) ? (pA - pB).abs() : null;
      }
      if (_limitsEnabled) {
        _pistonWithinA[i] = _within(pA, pistonMinVal, pistonMaxVal);
        if (_crossSections) {
          _pistonWithinB[i] = _within(pB, pistonMinVal, pistonMaxVal);
        }
      }
    }
    notifyListeners();
    saveData();
  }

  // Calculates ONLY Pin Bore, Wrist Pin, and Clearance specs
  void calculatePinSpecs() {
    _clearPinResults(); // Clear only pin results

    final pinBoreMinVal = _limitsEnabled ? _p(_pinBoreMin) : null;
    final pinBoreMaxVal = _limitsEnabled ? _p(_pinBoreMax) : null;
    final wristPinMinVal = _limitsEnabled ? _p(_wristPinMin) : null;
    final wristPinMaxVal = _limitsEnabled ? _p(_wristPinMax) : null;

    for (int i = 0; i < _numPistons; i++) {
      final pbA = _p(_measurements[i].pinBoreA);
      final pbB = _p(_measurements[i].pinBoreB);
      final wpOD = _p(_measurements[i].wristPinOd);

      // Pin Bore results
      if (_crossSections) {
        _pinBoreRoundness[i] = (pbA != null && pbB != null) ? (pbA - pbB).abs() : null;
      }
      if (_limitsEnabled) {
        _pinBoreWithinA[i] = _within(pbA, pinBoreMinVal, pinBoreMaxVal);
        _wristPinWithin[i] = _within(wpOD, wristPinMinVal, wristPinMaxVal);
        if (_crossSections) {
          _pinBoreWithinB[i] = _within(pbB, pinBoreMinVal, pinBoreMaxVal);
        }
      }

      // Pin Clearance
      double? boreForClearance = _crossSections
        ? (pbA != null && pbB != null ? (pbA + pbB) / 2.0 : pbA)
        : pbA;
      if (boreForClearance != null && wpOD != null) {
        _pinClearance[i] = boreForClearance - wpOD;
      } else {
        _pinClearance[i] = null;
      }
    }
    notifyListeners();
    saveData();
  }

  // Helper methods for calculation
  double? _p(String s) => double.tryParse(s.trim());
  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }

  // Clear ALL results
  void _clearResults() {
     _clearPistonResults();
     _clearPinResults();
  }

  // Clear only piston diameter results
  void _clearPistonResults(){
     for (int i = 0; i < _pistonRoundness.length; i++) {
      _pistonRoundness[i] = null;
      _pistonWithinA[i] = null;
      _pistonWithinB[i] = null;
    }
  }
   // Clear only pin-related results
   void _clearPinResults(){
      for (int i = 0; i < _pinBoreRoundness.length; i++) {
        _pinBoreRoundness[i] = null;
        _pinBoreWithinA[i] = null;
        _pinBoreWithinB[i] = null;
        _wristPinWithin[i] = null;
        _pinClearance[i] = null;
      }
   }

  // --- 5. LIST RESIZING --- (Unchanged)
  void _resizeLists() {
    void resizeSimpleList(List<dynamic> list) {
      while (list.length < _numPistons) list.add(null);
      while (list.length > _numPistons) list.removeLast();
    }
    while (_measurements.length < _numPistons) {
      _measurements.add(PistonMeasurement());
    }
    while (_measurements.length > _numPistons) {
      _measurements.removeLast();
    }
    resizeSimpleList(_pistonRoundness);
    resizeSimpleList(_pistonWithinA);
    resizeSimpleList(_pistonWithinB);
    resizeSimpleList(_pinBoreRoundness);
    resizeSimpleList(_pinBoreWithinA);
    resizeSimpleList(_pinBoreWithinB);
    resizeSimpleList(_wristPinWithin);
    resizeSimpleList(_pinClearance);
  }

  // --- 6. SAVE & LOAD --- (Unchanged)
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('piston_numPistons', _numPistons);
    prefs.setBool('piston_crossSections', _crossSections);
    prefs.setBool('piston_limitsEnabled', _limitsEnabled);
    prefs.setString('piston_pistonMin', _pistonMin);
    prefs.setString('piston_pistonMax', _pistonMax);
    prefs.setString('piston_pinBoreMin', _pinBoreMin);
    prefs.setString('piston_pinBoreMax', _pinBoreMax);
    prefs.setString('piston_wristPinMin', _wristPinMin);
    prefs.setString('piston_wristPinMax', _wristPinMax);
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
    _pistonMin = prefs.getString('piston_pistonMin') ?? '';
    _pistonMax = prefs.getString('piston_pistonMax') ?? '';
    _pinBoreMin = prefs.getString('piston_pinBoreMin') ?? '';
    _pinBoreMax = prefs.getString('piston_pinBoreMax') ?? '';
    _wristPinMin = prefs.getString('piston_wristPinMin') ?? '';
    _wristPinMax = prefs.getString('piston_wristPinMax') ?? '';
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
    // Calculate initial status on load
    calculatePistonSpecs(); // Calculate piston specs on load
    calculatePinSpecs(); // Calculate pin specs on load
  }
}