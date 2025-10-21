import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearhead_wizard/models/connecting_rod_measurement.dart';

class ConnectingRodProvider extends ChangeNotifier {
  int _numRods = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;

  String _bigMin = '';
  String _bigMax = '';
  String _pinMin = '';
  String _pinMax = '';

  List<ConnectingRodMeasurement> _measurements = [];

  final List<double?> _bigRound = [];
  final List<double?> _pinRound = [];
  final List<bool?> _bigWithinA = [];
  final List<bool?> _bigWithinB = [];
  final List<bool?> _pinWithinA = [];
  final List<bool?> _pinWithinB = [];

  int get numRods => _numRods;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;
  String get bigMin => _bigMin;
  String get bigMax => _bigMax;
  String get pinMin => _pinMin;
  String get pinMax => _pinMax;

  List<ConnectingRodMeasurement> get measurements => _measurements;
  List<double?> get bigRound => _bigRound;
  List<double?> get pinRound => _pinRound;
  List<bool?> get bigWithinA => _bigWithinA;
  List<bool?> get bigWithinB => _bigWithinB;
  List<bool?> get pinWithinA => _pinWithinA;
  List<bool?> get pinWithinB => _pinWithinB;

  void setNumRods(int n) {
    _numRods = n.clamp(1, 16);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  void updateBigA(int index, String value) {
    if (index < _measurements.length) _measurements[index].bigA = value;
  }
  void updateBigB(int index, String value) {
    if (index < _measurements.length) _measurements[index].bigB = value;
  }
  void updatePinA(int index, String value) {
    if (index < _measurements.length) _measurements[index].pinA = value;
  }
  void updatePinB(int index, String value) {
    if (index < _measurements.length) _measurements[index].pinB = value;
  }

  void updateBigMin(String value) => _bigMin = value;
  void updateBigMax(String value) => _bigMax = value;
  void updatePinMin(String value) => _pinMin = value;
  void updatePinMax(String value) => _pinMax = value;

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

    final bigMinVal = _limitsEnabled ? _p(_bigMin) : null;
    final bigMaxVal = _limitsEnabled ? _p(_bigMax) : null;
    final pinMinVal = _limitsEnabled ? _p(_pinMin) : null;
    final pinMaxVal = _limitsEnabled ? _p(_pinMax) : null;

    for (int i = 0; i < _numRods; i++) {
      final aB = _p(_measurements[i].bigA);
      final bB = _p(_measurements[i].bigB);
      final aP = _p(_measurements[i].pinA);
      final bP = _p(_measurements[i].pinB);

      if (_crossSections) {
        _bigRound[i] = (aB != null && bB != null) ? (aB - bB).abs() : null;
        _pinRound[i] = (aP != null && bP != null) ? (aP - bP).abs() : null;
      }

      if (_limitsEnabled) {
        _bigWithinA[i] = _within(aB, bigMinVal, bigMaxVal);
        _pinWithinA[i] = _within(aP, pinMinVal, pinMaxVal);

        if (_crossSections) {
          _bigWithinB[i] = _within(bB, bigMinVal, bigMaxVal);
          _pinWithinB[i] = _within(bP, pinMinVal, pinMaxVal);
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
    for (int i = 0; i < _numRods; i++) {
      _bigRound[i] = null;
      _pinRound[i] = null;
      _bigWithinA[i] = null;
      _bigWithinB[i] = null;
      _pinWithinA[i] = null;
      _pinWithinB[i] = null;
    }
  }

  void _resizeLists() {
    while (_measurements.length < _numRods) {
      _measurements.add(ConnectingRodMeasurement());
    }
    while (_measurements.length > _numRods) {
      _measurements.removeLast();
    }
    
    void resizeResultList(List<dynamic> list) {
      while (list.length < _numRods) {
        list.add(null);
      }
      while (list.length > _numRods) {
        list.removeLast();
      }
    }
    resizeResultList(_bigRound);
    resizeResultList(_pinRound);
    resizeResultList(_bigWithinA);
    resizeResultList(_bigWithinB);
    resizeResultList(_pinWithinA);
    resizeResultList(_pinWithinB);
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setInt('rod_numRods', _numRods);
    prefs.setBool('rod_crossSections', _crossSections);
    prefs.setBool('rod_limitsEnabled', _limitsEnabled);
    prefs.setString('rod_bigMin', _bigMin);
    prefs.setString('rod_bigMax', _bigMax);
    prefs.setString('rod_pinMin', _pinMin);
    prefs.setString('rod_pinMax', _pinMax);
    
    List<Map<String, dynamic>> jsonList = 
        _measurements.map((p) => p.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    prefs.setString('rod_measurements', jsonString);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _numRods = prefs.getInt('rod_numRods') ?? 8;
    _crossSections = prefs.getBool('rod_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('rod_limitsEnabled') ?? false;
    _bigMin = prefs.getString('rod_bigMin') ?? '';
    _bigMax = prefs.getString('rod_bigMax') ?? '';
    _pinMin = prefs.getString('rod_pinMin') ?? '';
    _pinMax = prefs.getString('rod_pinMax') ?? '';

    try {
      final String? jsonString = prefs.getString('rod_measurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _measurements = jsonList
            .map((jsonItem) => ConnectingRodMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _measurements = [];
    }
    _resizeLists();
  }
}