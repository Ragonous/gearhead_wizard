import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearhead_wizard/models/main_journal_measurement.dart';
import 'package:gearhead_wizard/models/rod_journal_measurement.dart';

class CrankshaftProvider extends ChangeNotifier {
  // --- 1. INTERNAL DATA ---
  int _numMains = 5;
  int _numRods = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;

  String _mainMin = '';
  String _mainMax = '';
  String _rodMin = '';
  String _rodMax = '';
  String _crankEndplay = '';
  String _crankEndplayMin = '';
  String _crankEndplayMax = '';

  List<MainJournalMeasurement> _mainMeasurements = [];
  List<RodJournalMeasurement> _rodMeasurements = [];

  final List<double?> _mainRoundness = [];
  final List<double?> _rodRoundness = [];
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _rodWithinA = [];
  final List<bool?> _rodWithinB = [];
  bool? _crankEndplayWithin;


  // --- 2. GETTERS ---
  int get numMains => _numMains;
  int get numRods => _numRods;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;

  String get mainMin => _mainMin;
  String get mainMax => _mainMax;
  String get rodMin => _rodMin;
  String get rodMax => _rodMax;
  String get crankEndplay => _crankEndplay;
  String get crankEndplayMin => _crankEndplayMin;
  String get crankEndplayMax => _crankEndplayMax;

  List<MainJournalMeasurement> get mainMeasurements => _mainMeasurements;
  List<RodJournalMeasurement> get rodMeasurements => _rodMeasurements;

  List<double?> get mainRoundness => _mainRoundness;
  List<double?> get rodRoundness => _rodRoundness;
  List<bool?> get mainWithinA => _mainWithinA;
  List<bool?> get mainWithinB => _mainWithinB;
  List<bool?> get rodWithinA => _rodWithinA;
  List<bool?> get rodWithinB => _rodWithinB;
  bool? get crankEndplayWithin => _crankEndplayWithin;


  // --- 3. METHODS ---
  void setNumMains(int n) {
    _numMains = n.clamp(1, 10);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  void setNumRods(int n) {
    _numRods = n.clamp(1, 16);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData();
  }

  void updateMainA(int index, String value) {
    if (index < _mainMeasurements.length) _mainMeasurements[index].a = value;
  }
  void updateMainB(int index, String value) {
    if (index < _mainMeasurements.length) _mainMeasurements[index].b = value;
  }
  void updateRodA(int index, String value) {
    if (index < _rodMeasurements.length) _rodMeasurements[index].a = value;
  }
  void updateRodB(int index, String value) {
    if (index < _rodMeasurements.length) _rodMeasurements[index].b = value;
  }

  void updateMainMin(String value) => _mainMin = value;
  void updateMainMax(String value) => _mainMax = value;
  void updateRodMin(String value) => _rodMin = value;
  void updateRodMax(String value) => _rodMax = value;
  void updateCrankEndplay(String value) => _crankEndplay = value;
  void updateCrankEndplayMin(String value) => _crankEndplayMin = value;
  void updateCrankEndplayMax(String value) => _crankEndplayMax = value;

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

  // Main calculate method - calculates EVERYTHING
  void calculate() {
    _clearResults(); // Clear all results

    final mainMinVal = _limitsEnabled ? _p(_mainMin) : null;
    final mainMaxVal = _limitsEnabled ? _p(_mainMax) : null;
    final rodMinVal = _limitsEnabled ? _p(_rodMin) : null;
    final rodMaxVal = _limitsEnabled ? _p(_rodMax) : null;

    // Calculate Mains
    for (int i = 0; i < _numMains; i++) {
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

    // Calculate Rods
    for (int i = 0; i < _numRods; i++) {
      final a = _p(_rodMeasurements[i].a);
      final b = _p(_rodMeasurements[i].b);
      if (_crossSections) {
        _rodRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
      }
      if (_limitsEnabled) {
        _rodWithinA[i] = _within(a, rodMinVal, rodMaxVal);
        if (_crossSections) {
          _rodWithinB[i] = _within(b, rodMinVal, rodMaxVal);
        }
      }
    }

    // Calculate Endplay Status (also done here for the main button)
    calculateEndplayStatus(notify: false); // Use the helper, don't notify yet

    notifyListeners(); // Notify UI once after all calculations
    saveData(); // Save everything
  }

  // <<< NEW METHOD >>> Calculates *only* endplay status
  void calculateEndplayStatus({bool notify = true}) {
     if (_limitsEnabled) {
      final endplayMinVal = _p(_crankEndplayMin);
      final endplayMaxVal = _p(_crankEndplayMax);
      final endplayVal = _p(_crankEndplay);
      _crankEndplayWithin = _within(endplayVal, endplayMinVal, endplayMaxVal);
    } else {
      _crankEndplayWithin = null;
    }
     // Only notify if called directly (e.g., from the new button)
     if (notify) {
       notifyListeners();
       saveData(); // Save when calculated individually too
     }
  }


  double? _p(String s) => double.tryParse(s.trim());

  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }

  // Updated to clear endplay status too
  void _clearResults() {
    for (int i = 0; i < _mainRoundness.length; i++) {
      _mainRoundness[i] = null;
      _mainWithinA[i] = null;
      _mainWithinB[i] = null;
    }
    for (int i = 0; i < _rodRoundness.length; i++) {
      _rodRoundness[i] = null;
      _rodWithinA[i] = null;
      _rodWithinB[i] = null;
    }
    _crankEndplayWithin = null; // Clear endplay
  }

  // --- 5. LIST RESIZING ---
  // (No change needed)
  void _resizeLists() {
    void resizeList(List<dynamic> list, int targetSize) {
      while (list.length < targetSize) list.add(null);
      while (list.length > targetSize) list.removeLast();
    }

    while (_mainMeasurements.length < _numMains) {
      _mainMeasurements.add(MainJournalMeasurement());
    }
    while (_mainMeasurements.length > _numMains) {
      _mainMeasurements.removeLast();
    }

    while (_rodMeasurements.length < _numRods) {
      _rodMeasurements.add(RodJournalMeasurement());
    }
    while (_rodMeasurements.length > _numRods) {
      _rodMeasurements.removeLast();
    }

    resizeList(_mainRoundness, _numMains);
    resizeList(_mainWithinA, _numMains);
    resizeList(_mainWithinB, _numMains);

    resizeList(_rodRoundness, _numRods);
    resizeList(_rodWithinA, _numRods);
    resizeList(_rodWithinB, _numRods);
  }

  // --- 6. SAVE & LOAD ---
  // (No change needed, endplay specs already included)
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('crank_numMains', _numMains);
    prefs.setInt('crank_numRods', _numRods);
    prefs.setBool('crank_crossSections', _crossSections);
    prefs.setBool('crank_limitsEnabled', _limitsEnabled);
    prefs.setString('crank_mainMin', _mainMin);
    prefs.setString('crank_mainMax', _mainMax);
    prefs.setString('crank_rodMin', _rodMin);
    prefs.setString('crank_rodMax', _rodMax);
    prefs.setString('crank_crankEndplay', _crankEndplay);
    prefs.setString('crank_crankEndplayMin', _crankEndplayMin);
    prefs.setString('crank_crankEndplayMax', _crankEndplayMax);

    List<Map<String, dynamic>> mainJsonList =
        _mainMeasurements.map((p) => p.toJson()).toList();
    prefs.setString('crank_mainMeasurements', jsonEncode(mainJsonList));

    List<Map<String, dynamic>> rodJsonList =
        _rodMeasurements.map((p) => p.toJson()).toList();
    prefs.setString('crank_rodMeasurements', jsonEncode(rodJsonList));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _numMains = prefs.getInt('crank_numMains') ?? 5;
    _numRods = prefs.getInt('crank_numRods') ?? 8;
    _crossSections = prefs.getBool('crank_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('crank_limitsEnabled') ?? false;
    _mainMin = prefs.getString('crank_mainMin') ?? '';
    _mainMax = prefs.getString('crank_mainMax') ?? '';
    _rodMin = prefs.getString('crank_rodMin') ?? '';
    _rodMax = prefs.getString('crank_rodMax') ?? '';
    _crankEndplay = prefs.getString('crank_crankEndplay') ?? '';
    _crankEndplayMin = prefs.getString('crank_crankEndplayMin') ?? '';
    _crankEndplayMax = prefs.getString('crank_crankEndplayMax') ?? '';

    try {
      final String? jsonString = prefs.getString('crank_mainMeasurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _mainMeasurements = jsonList
            .map((jsonItem) => MainJournalMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _mainMeasurements = [];
    }

    try {
      final String? jsonString = prefs.getString('crank_rodMeasurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _rodMeasurements = jsonList
            .map((jsonItem) => RodJournalMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _rodMeasurements = [];
    }

    _resizeLists();

    // Calculate endplay status on load
    calculateEndplayStatus(notify: false); // Use helper, don't notify yet
  }
}