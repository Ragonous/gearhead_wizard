import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enums moved here from the UI file
enum TransType { manual, automatic }
enum DriveType { twoWD, fourWD }

class GearRatioProvider extends ChangeNotifier {
  // --- 1. INTERNAL DATA ---
  // Tire
  bool _useMetricTires = false;
  String _tireDia = '26.0';
  String _tireMetric = '275/40R18';

  // Driveline
  String _axleRatio = '3.73';
  DriveType _drive = DriveType.twoWD;
  String _tcaseHigh = '1.00';
  String _tcaseLow = '2.72';
  String _range = 'High'; // High | Low

  // Transmission
  TransType _transType = TransType.manual;
  int _numGears = 5;
  List<String> _gearRatios = [ // Store only the text values
    '2.95', '1.94', '1.34', '1.00', '0.73'
  ];

  // Splitter
  bool _splitterEnabled = false;
  String _splitterRatio = '0.78';
  bool _splitterEngaged = false;

  // Calculation inputs/state
  String _mph = '65';
  String _rpm = '2500';
  int _selectedGearIndex = 3; // Index for calculation

  // Results
  double? _rpmAtMph;
  double? _mphAtRpm;

  // --- 2. GETTERS ---
  bool get useMetricTires => _useMetricTires;
  String get tireDia => _tireDia;
  String get tireMetric => _tireMetric;
  String get axleRatio => _axleRatio;
  DriveType get drive => _drive;
  String get tcaseHigh => _tcaseHigh;
  String get tcaseLow => _tcaseLow;
  String get range => _range;
  TransType get transType => _transType;
  int get numGears => _numGears;
  List<String> get gearRatios => _gearRatios;
  bool get splitterEnabled => _splitterEnabled;
  String get splitterRatio => _splitterRatio;
  bool get splitterEngaged => _splitterEngaged;
  String get mph => _mph;
  String get rpm => _rpm;
  int get selectedGearIndex => _selectedGearIndex;
  double? get rpmAtMph => _rpmAtMph;
  double? get mphAtRpm => _mphAtRpm;

  // --- 3. METHODS (Called from UI) ---
  // Tire Updates
  void setUseMetricTires(bool value) {
    _useMetricTires = value;
    notifyListeners();
    saveData();
  }
  void updateTireDia(String value) => _tireDia = value;
  void updateTireMetric(String value) => _tireMetric = value;

  // Driveline Updates
  void updateAxleRatio(String value) => _axleRatio = value;
  void setDriveType(DriveType value) {
    _drive = value;
    notifyListeners();
    saveData();
  }
  void updateTcaseHigh(String value) => _tcaseHigh = value;
  void updateTcaseLow(String value) => _tcaseLow = value;
  void setRange(String value) {
    _range = value;
    notifyListeners();
    saveData();
  }

  // Transmission Updates
  void setTransType(TransType value) {
    _transType = value;
    notifyListeners();
    saveData();
  }
  void setNumGears(int n) {
    final clamped = n.clamp(1, 10);
    if (clamped == _numGears) return;

    // Grow list
    while (_gearRatios.length < clamped) {
      _gearRatios.add('');
    }
    // Shrink list
    while (_gearRatios.length > clamped) {
      _gearRatios.removeLast();
    }
    _numGears = clamped;

    // Adjust selected gear if out of bounds
    if (_selectedGearIndex >= _numGears) {
      _selectedGearIndex = _numGears - 1;
    }
    notifyListeners();
    saveData();
  }
  void updateGearRatio(int index, String value) {
    if (index < _gearRatios.length) {
      _gearRatios[index] = value;
    }
  }

  // Splitter Updates
  void setSplitterEnabled(bool value) {
    _splitterEnabled = value;
    notifyListeners();
    saveData();
  }
  void updateSplitterRatio(String value) => _splitterRatio = value;
  void setSplitterEngaged(bool value) {
    _splitterEngaged = value;
    notifyListeners();
    // No need to save this, it's transient state for calculation
  }

  // Calculation Inputs/State Updates
  void updateMph(String value) => _mph = value;
  void updateRpm(String value) => _rpm = value;
  void setSelectedGearIndex(int value) {
    _selectedGearIndex = value.clamp(0, _numGears - 1);
    notifyListeners();
    // No need to save this index, save the ratios instead
  }

  // --- 4. CALCULATION LOGIC ---
  double? _p(String s) => double.tryParse(s.trim());

  double _getTireDiameterInches() {
    if (!_useMetricTires) return _p(_tireDia) ?? 0;
    return _parseMetricTire(_tireMetric);
  }

  double _parseMetricTire(String s) {
    final m =
        RegExp(r'(\d{3})/(\d{2})R(\d{2})', caseSensitive: false).firstMatch(s);
    if (m == null) return 0;
    final width = double.tryParse(m.group(1)!) ?? 0;
    final aspect = double.tryParse(m.group(2)!) ?? 0;
    final rimIn = double.tryParse(m.group(3)!) ?? 0;
    final sidewallMm = width * (aspect / 100.0);
    final diameterMm = 2 * sidewallMm + rimIn * 25.4;
    return diameterMm / 25.4;
  }

  double _effectiveFinalDrive() {
    final axle = _p(_axleRatio) ?? 0;
    final tHigh = _p(_tcaseHigh) ?? 1.0;
    final tLow = _p(_tcaseLow) ?? 1.0;
    final tCase = (_drive == DriveType.fourWD) ? (_range == 'Low' ? tLow : tHigh) : 1.0;
    final split = (_splitterEnabled && _splitterEngaged) ? (_p(_splitterRatio) ?? 1.0) : 1.0;
    return axle * tCase * split;
  }

  double _selectedGearRatioValue() {
    final idx = _selectedGearIndex.clamp(0, _numGears - 1);
    final g = _p(_gearRatios[idx]);
    return (g == null || g <= 0) ? 1.0 : g;
  }

  // Calculation methods called by UI
  String? calcRpmAtMph() {
    final d = _getTireDiameterInches();
    final mphVal = _p(_mph);
    if (d <= 0 || mphVal == null || mphVal < 0) {
      _rpmAtMph = null;
      notifyListeners();
      return 'Enter valid tire and MPH.';
    }
    final rpmResult = (mphVal * _selectedGearRatioValue() * _effectiveFinalDrive() * 336.0) / d;
    _rpmAtMph = rpmResult;
    notifyListeners();
    saveData(); // Save inputs after successful calculation
    return null; // No error
  }

  String? calcMphAtRpm() {
    final d = _getTireDiameterInches();
    final rpmVal = _p(_rpm);
    if (d <= 0 || rpmVal == null || rpmVal < 0) {
      _mphAtRpm = null;
      notifyListeners();
      return 'Enter valid tire and RPM.';
    }
    final mphResult = (rpmVal * d) / (_selectedGearRatioValue() * _effectiveFinalDrive() * 336.0);
    _mphAtRpm = mphResult;
    notifyListeners();
    saveData(); // Save inputs after successful calculation
    return null; // No error
  }

  // --- 5. SAVE & LOAD ---
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setBool('gear_useMetricTires', _useMetricTires);
    prefs.setString('gear_tireDia', _tireDia);
    prefs.setString('gear_tireMetric', _tireMetric);
    prefs.setString('gear_axleRatio', _axleRatio);
    prefs.setInt('gear_drive', _drive.index); // Save enum index
    prefs.setString('gear_tcaseHigh', _tcaseHigh);
    prefs.setString('gear_tcaseLow', _tcaseLow);
    prefs.setString('gear_range', _range);
    prefs.setInt('gear_transType', _transType.index); // Save enum index
    prefs.setInt('gear_numGears', _numGears);
    prefs.setStringList('gear_gearRatios', _gearRatios); // Save list of strings
    prefs.setBool('gear_splitterEnabled', _splitterEnabled);
    prefs.setString('gear_splitterRatio', _splitterRatio);
    prefs.setString('gear_mph', _mph);
    prefs.setString('gear_rpm', _rpm);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _useMetricTires = prefs.getBool('gear_useMetricTires') ?? false;
    _tireDia = prefs.getString('gear_tireDia') ?? '26.0';
    _tireMetric = prefs.getString('gear_tireMetric') ?? '275/40R18';
    _axleRatio = prefs.getString('gear_axleRatio') ?? '3.73';
    _drive = DriveType.values[prefs.getInt('gear_drive') ?? DriveType.twoWD.index];
    _tcaseHigh = prefs.getString('gear_tcaseHigh') ?? '1.00';
    _tcaseLow = prefs.getString('gear_tcaseLow') ?? '2.72';
    _range = prefs.getString('gear_range') ?? 'High';
    _transType = TransType.values[prefs.getInt('gear_transType') ?? TransType.manual.index];
    _numGears = prefs.getInt('gear_numGears') ?? 5;
    _gearRatios = prefs.getStringList('gear_gearRatios') ?? // Load list
        ['2.95', '1.94', '1.34', '1.00', '0.73']; // Default if not found
    _splitterEnabled = prefs.getBool('gear_splitterEnabled') ?? false;
    _splitterRatio = prefs.getString('gear_splitterRatio') ?? '0.78';
    _mph = prefs.getString('gear_mph') ?? '65';
    _rpm = prefs.getString('gear_rpm') ?? '2500';

    // Ensure gear ratio list has correct length after loading
    _resizeGearList();
    
    // Set default selected gear index (can't save this easily)
    _selectedGearIndex = (_numGears > 3) ? 3 : (_numGears - 1).clamp(0, 9);
    
    // No need to calculate on load for this page
  }
  
  // Helper to ensure gear list matches numGears after loading
  void _resizeGearList() {
    while (_gearRatios.length < _numGears) {
      _gearRatios.add('');
    }
    while (_gearRatios.length > _numGears) {
      _gearRatios.removeLast();
    }
  }
}