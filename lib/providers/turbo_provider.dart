import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TurboProvider extends ChangeNotifier {
  String _naHp = '300';
  String _boostPsi = '8';
  String _efficiency = '0.90';
  double? _pressureRatio;
  double? _boostedHp;

  String get naHp => _naHp;
  String get boostPsi => _boostPsi;
  String get efficiency => _efficiency;
  double? get pressureRatio => _pressureRatio;
  double? get boostedHp => _boostedHp;

  void updateNaHp(String value) {
    _naHp = value;
  }
  void updateBoostPsi(String value) {
    _boostPsi = value;
  }
  void updateEfficiency(String value) {
    _efficiency = value;
  }

  String? calculate() {
    final naHpVal = double.tryParse(_naHp);
    final boostPsiVal = double.tryParse(_boostPsi);
    final effVal = double.tryParse(_efficiency);

    if (naHpVal == null || boostPsiVal == null || effVal == null) {
      _pressureRatio = null;
      _boostedHp = null;
      notifyListeners();
      return 'Please enter valid numbers.';
    }
    if (effVal <= 0 || effVal > 1.2) {
      _pressureRatio = null;
      _boostedHp = null;
      notifyListeners();
      return 'Efficiency should be ~0.70–1.00.';
    }

    _pressureRatio = (boostPsiVal + 14.7) / 14.7;
    _boostedHp = naHpVal * _pressureRatio! * effVal;

    notifyListeners();
    saveData();
    return null;
  }

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
    calculate();
  }
}