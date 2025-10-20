import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is our new "brain" for the Turbo Calculator.
// It uses "ChangeNotifier" to tell the UI when to update.
class TurboProvider extends ChangeNotifier {
  // 1. Private variables for inputs
  String _naHp = '300';
  String _boostPsi = '8';
  String _efficiency = '0.90';

  // 2. Private variables for results
  double? _pressureRatio;
  double? _boostedHp;

  // 3. "Getters" so the UI can read this data
  String get naHp => _naHp;
  String get boostPsi => _boostPsi;
  String get efficiency => _efficiency;
  double? get pressureRatio => _pressureRatio;
  double? get boostedHp => _boostedHp;

  // 4. Methods to update the data (called from the UI)
  void updateNaHp(String value) {
    _naHp = value;
  }
  void updateBoostPsi(String value) {
    _boostPsi = value;
  }
  void updateEfficiency(String value) {
    _efficiency = value;
  }

  // 5. The calculation logic (moved from your UI file)
  String? calculate() {
    final naHpVal = double.tryParse(_naHp);
    final boostPsiVal = double.tryParse(_boostPsi);
    final effVal = double.tryParse(_efficiency);

    // Error checking
    if (naHpVal == null || boostPsiVal == null || effVal == null) {
      _pressureRatio = null;
      _boostedHp = null;
      notifyListeners(); // Tell UI to clear results
      return 'Please enter valid numbers.'; // Return error message
    }
    if (effVal <= 0 || effVal > 1.2) {
      _pressureRatio = null;
      _boostedHp = null;
      notifyListeners(); // Tell UI to clear results
      return 'Efficiency should be ~0.70–1.00.'; // Return error
    }

    // Do the math
    _pressureRatio = (boostPsiVal + 14.7) / 14.7;
    _boostedHp = naHpVal * _pressureRatio! * effVal;

    notifyListeners(); // Tell the UI to update with new results
    saveData(); // Save the new data to our "notebook"
    return null; // No error
  }

  // 6. The "Notebook" methods
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('turbo_naHp', _naHp);
    prefs.setString('turbo_boostPsi', _boostPsi);
    prefs.setString('turbo_efficiency', _efficiency);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _naHp = prefs.getString('turbo_naHp') ?? '300';
    _boostPsi = prefs.getString('turbo_boostPsi') ?? '8';
    _efficiency = prefs.getString('turbo_efficiency') ?? '0.90';
    
    // Calculate on load, so results are ready
    calculate();
  }
}