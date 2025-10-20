import 'dart:convert'; // We need this to encode/decode JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/piston_measurement.dart';

class PistonProvider extends ChangeNotifier {
  // --- 1. INTERNAL DATA ---
  // All our data is private. The UI cannot change it directly.
  int _numPistons = 8;
  bool _crossSections = false;
  bool _limitsEnabled = false;

  String _min = '';
  String _max = '';

  // Our list of data models
  List<PistonMeasurement> _measurements = [];

  // Our lists for results
  List<double?> _roundness = [];
  List<bool?> _withinA = [];
  List<bool?> _withinB = [];

  // --- 2. GETTERS ---
  // This is how the UI *reads* our data
  int get numPistons => _numPistons;
  bool get crossSections => _crossSections;
  bool get limitsEnabled => _limitsEnabled;
  String get min => _min;
  String get max => _max;
  List<PistonMeasurement> get measurements => _measurements;
  List<double?> get roundness => _roundness;
  List<bool?> get withinA => _withinA;
  List<bool?> get withinB => _withinB;

  // --- 3. METHODS (Things the UI can do) ---

  // Called from UI to set the number of pistons
  void setNumPistons(int n) {
    _numPistons = n.clamp(1, 16);
    _resizeLists(); // Resize all our lists
    _clearResults();
    notifyListeners(); // Tell the UI to rebuild
    saveData(); // Save changes
  }

  // Called from UI to update a single 'A' text value
  void updateMeasurementA(int index, String value) {
    if (index < _measurements.length) {
      _measurements[index].a = value;
      // We don't notifyListeners() here,
      // as it's more efficient to just update on "Calculate".
    }
  }

  // Called from UI to update a single 'B' text value
  void updateMeasurementB(int index, String value) {
    if (index < _measurements.length) {
      _measurements[index].b = value;
    }
  }

  // Called from UI to update the Min/Max text values
  void updateMin(String value) {
    _min = value;
  }
  void updateMax(String value) {
    _max = value;
  }

  // Called from UI toggles
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

  // --- 4. CALCULATION LOGIC ---
  // This logic is moved straight from your old page
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
    
    notifyListeners(); // Tell UI to show new results
    saveData(); // Save the new data (A/B values)
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

  // --- 5. HELPER TO MANAGE LISTS ---
  // This is your _resizeLists logic, now inside the provider
  void _resizeLists() {
    // Grow or shrink the data list
    while (_measurements.length < _numPistons) {
      _measurements.add(PistonMeasurement());
    }
    while (_measurements.length > _numPistons) {
      _measurements.removeLast();
    }
    
    // Grow or shrink result lists
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

  // --- 6. SAVE & LOAD (The "Notebook") ---
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save simple values
    prefs.setInt('piston_numPistons', _numPistons);
    prefs.setBool('piston_crossSections', _crossSections);
    prefs.setBool('piston_limitsEnabled', _limitsEnabled);
    prefs.setString('piston_min', _min);
    prefs.setString('piston_max', _max);
    
    // Save the list by converting it to a JSON string
    // 1. Convert List<PistonMeasurement> to List<Map<String, dynamic>>
    List<Map<String, dynamic>> jsonList = 
        _measurements.map((p) => p.toJson()).toList();
    // 2. Encode the list into a single string
    String jsonString = jsonEncode(jsonList);
    // 3. Save the string
    prefs.setString('piston_measurements', jsonString);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load simple values
    _numPistons = prefs.getInt('piston_numPistons') ?? 8;
    _crossSections = prefs.getBool('piston_crossSections') ?? false;
    _limitsEnabled = prefs.getBool('piston_limitsEnabled') ?? false;
    _min = prefs.getString('piston_min') ?? '';
    _max = prefs.getString('piston_max') ?? '';

    // Load the list
    try {
      final String? jsonString = prefs.getString('piston_measurements');
      if (jsonString != null) {
        // 1. Decode the string back into a List<dynamic>
        List<dynamic> jsonList = jsonDecode(jsonString);
        // 2. Convert that list into our proper List<PistonMeasurement>
        _measurements = jsonList
            .map((jsonItem) => PistonMeasurement.fromJson(jsonItem))
            .toList();
      }
    } catch (e) {
      // If something goes wrong (e.g., saved data is corrupt),
      // just clear the measurements.
      _measurements = [];
    }

    // IMPORTANT: Make sure all lists are the correct size after loading
    _resizeLists();
  }
}