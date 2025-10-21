import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gearhead_wizard/models/camshaft_journal_measurement.dart';

class CamshaftProvider extends ChangeNotifier {
  // --- INTERNAL DATA --- (Unchanged)
  int _numJournals = 5;
  bool _crossSections = false;
  bool _limitsEnabled = false;
  String _journalMin = '';
  String _journalMax = '';
  String _camEndplay = '';
  String _camEndplayMin = '';
  String _camEndplayMax = '';
  List<CamshaftJournalMeasurement> _journalMeasurements = [];
  final List<double?> _journalRoundness = [];
  final List<bool?> _journalWithinA = [];
  final List<bool?> _journalWithinB = [];
  bool? _camEndplayWithin;

  // --- GETTERS --- (Unchanged)
  int get numJournals => _numJournals;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;
  String get journalMin => _journalMin;
  String get journalMax => _journalMax;
  String get camEndplay => _camEndplay;
  String get camEndplayMin => _camEndplayMin;
  String get camEndplayMax => _camEndplayMax;
  List<CamshaftJournalMeasurement> get journalMeasurements => _journalMeasurements;
  List<double?> get journalRoundness => _journalRoundness;
  List<bool?> get journalWithinA => _journalWithinA;
  List<bool?> get journalWithinB => _journalWithinB;
  bool? get camEndplayWithin => _camEndplayWithin;

  // --- METHODS --- (Unchanged)
  void setNumJournals(int n) {
    _numJournals = n.clamp(1, 10);
    _resizeLists();
    _clearResults();
    notifyListeners();
    saveData(); // Save structural changes immediately
  }
  void updateJournalA(int index, String value) {
    if (index < _journalMeasurements.length) _journalMeasurements[index].a = value;
  }
  void updateJournalB(int index, String value) {
    if (index < _journalMeasurements.length) _journalMeasurements[index].b = value;
  }
  void updateJournalMin(String value) => _journalMin = value;
  void updateJournalMax(String value) => _journalMax = value;
  void updateCamEndplay(String value) => _camEndplay = value;
  void updateCamEndplayMin(String value) => _camEndplayMin = value;
  void updateCamEndplayMax(String value) => _camEndplayMax = value;
  void setCrossSections(bool value) {
    _crossSections = value;
    _clearResults();
    notifyListeners();
    saveData(); // Save toggle changes immediately
  }
  void setLimitsEnabled(bool value) {
    _limitsEnabled = value;
    _clearResults();
    notifyListeners();
    saveData(); // Save toggle changes immediately
  }

  // --- 4. CALCULATION --- (Split Confirmed)

  // Calculates ONLY Journal Specs
  void calculateJournalSpecs() {
    _clearJournalResults(); // Clear only relevant results
    final journalMinVal = _limitsEnabled ? _p(_journalMin) : null;
    final journalMaxVal = _limitsEnabled ? _p(_journalMax) : null;

    for (int i = 0; i < _numJournals; i++) {
      final a = _p(_journalMeasurements[i].a);
      final b = _p(_journalMeasurements[i].b);
      if (_crossSections) {
        _journalRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
      }
      if (_limitsEnabled) {
        _journalWithinA[i] = _within(a, journalMinVal, journalMaxVal);
        if (_crossSections) {
          _journalWithinB[i] = _within(b, journalMinVal, journalMaxVal);
        }
      }
    }
    notifyListeners(); // Update UI
    saveData(); // Save latest inputs and results
  }

  // Calculates ONLY Endplay Status
  void calculateEndplayStatus() {
     if (_limitsEnabled) {
      final endplayMinVal = _p(_camEndplayMin);
      final endplayMaxVal = _p(_camEndplayMax);
      final endplayVal = _p(_camEndplay);
      _camEndplayWithin = _within(endplayVal, endplayMinVal, endplayMaxVal);
    } else {
      _camEndplayWithin = null; // Ensure null if limits off
    }
    notifyListeners(); // Update UI
    saveData(); // Save latest inputs and result
  }

  // Helpers (Unchanged)
  double? _p(String s) => double.tryParse(s.trim());
  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }
  void _clearResults() {
    _clearJournalResults();
    _camEndplayWithin = null;
  }
  void _clearJournalResults(){
     for (int i = 0; i < _journalRoundness.length; i++) {
      _journalRoundness[i] = null;
      _journalWithinA[i] = null;
      _journalWithinB[i] = null;
    }
  }

  // --- 5. LIST RESIZING --- (Unchanged)
  void _resizeLists() {
    void resizeSimpleList(List<dynamic> list, int targetSize) {
      while (list.length < targetSize) list.add(null);
      while (list.length > targetSize) list.removeLast();
    }
    while (_journalMeasurements.length < _numJournals) {
      _journalMeasurements.add(CamshaftJournalMeasurement());
    }
    while (_journalMeasurements.length > _numJournals) {
      _journalMeasurements.removeLast();
    }
    resizeSimpleList(_journalRoundness, _numJournals);
    resizeSimpleList(_journalWithinA, _numJournals);
    resizeSimpleList(_journalWithinB, _numJournals);
  }

  // --- 6. SAVE & LOAD --- (Unchanged)
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cam_numJournals', _numJournals);
    prefs.setBool('cam_crossSections', _crossSections);
    prefs.setBool('cam_limitsEnabled', _limitsEnabled);
    prefs.setString('cam_journalMin', _journalMin);
    prefs.setString('cam_journalMax', _journalMax);
    prefs.setString('cam_camEndplay', _camEndplay);
    prefs.setString('cam_camEndplayMin', _camEndplayMin);
    prefs.setString('cam_camEndplayMax', _camEndplayMax);
    List<Map<String, dynamic>> jsonList =
        _journalMeasurements.map((p) => p.toJson()).toList();
    prefs.setString('cam_journalMeasurements', jsonEncode(jsonList));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _numJournals = prefs.getInt('cam_numJournals') ?? 5;
    _crossSections = prefs.getBool('cam_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('cam_limitsEnabled') ?? false;
    _journalMin = prefs.getString('cam_journalMin') ?? '';
    _journalMax = prefs.getString('cam_journalMax') ?? '';
    _camEndplay = prefs.getString('cam_camEndplay') ?? '';
    _camEndplayMin = prefs.getString('cam_camEndplayMin') ?? '';
    _camEndplayMax = prefs.getString('cam_camEndplayMax') ?? '';
    try {
      final String? jsonString = prefs.getString('cam_journalMeasurements');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _journalMeasurements = jsonList
            .map((jsonItem) => CamshaftJournalMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      _journalMeasurements = [];
    }
    _resizeLists();
    // Calculate initial status on load using the specific methods
    calculateJournalSpecs(); // Recalculate journal status on load
    calculateEndplayStatus(); // Recalculate endplay status on load
  }
}