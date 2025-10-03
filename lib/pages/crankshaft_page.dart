import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

class CrankshaftPage extends StatefulWidget {
  const CrankshaftPage({super.key});
  @override
  State<CrankshaftPage> createState() => _CrankshaftPageState();
}

class _CrankshaftPageState extends State<CrankshaftPage> {
  // Counts
  int _numMains = 5;
  int _numRods = 8;

  final TextEditingController _numMainsCtrl = TextEditingController(text: '5');
  final TextEditingController _numRodsCtrl = TextEditingController(text: '8');

  // Cross-section toggle (two measurements per journal at ~90° apart)
  bool _crossSections = false;

  // Manufacturer limits toggle
  bool _limitsEnabled = false;
  final TextEditingController _mainMinCtrl = TextEditingController();
  final TextEditingController _mainMaxCtrl = TextEditingController();
  final TextEditingController _rodMinCtrl = TextEditingController();
  final TextEditingController _rodMaxCtrl = TextEditingController();

  // Measurement controllers
  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _rodA = [];
  final List<TextEditingController> _rodB = [];

  // Results (in same units as inputs)
  final List<double?> _mainRoundness = [];
  final List<double?> _rodRoundness = [];

  // Limits results (null = not computed / not applicable)
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _rodWithinA = [];
  final List<bool?> _rodWithinB = [];

  @override
  void initState() {
    super.initState();
    _resizeLists();
  }

  @override
  void dispose() {
    _numMainsCtrl.dispose();
    _numRodsCtrl.dispose();
    _mainMinCtrl.dispose();
    _mainMaxCtrl.dispose();
    _rodMinCtrl.dispose();
    _rodMaxCtrl.dispose();
    for (final c in _mainA) {
      c.dispose();
    }
    for (final c in _mainB) {
      c.dispose();
    }
    for (final c in _rodA) {
      c.dispose();
    }
    for (final c in _rodB) {
      c.dispose();
    }
    super.dispose();
  }

  // --- ensure controller/result list sizes are always correct ---
  void _resizeLists() {
    _numMains = _numMains.clamp(1, 10);
    _numRods = _numRods.clamp(1, 16);

    void grow(List<TextEditingController> list, int to) {
      while (list.length < to) {
        list.add(TextEditingController());
      }
    }

    void shrink(List<TextEditingController> list, int to) {
      while (list.length > to) {
        list.removeLast().dispose();
      }
    }

    grow(_mainA, _numMains);
    grow(_mainB, _numMains);
    grow(_rodA, _numRods);
    grow(_rodB, _numRods);
    shrink(_mainA, _numMains);
    shrink(_mainB, _numMains);
    shrink(_rodA, _numRods);
    shrink(_rodB, _numRods);

    while (_mainRoundness.length < _numMains) {
      _mainRoundness.add(null);
    }
    while (_mainRoundness.length > _numMains) {
      _mainRoundness.removeLast();
    }
    while (_rodRoundness.length < _numRods) {
      _rodRoundness.add(null);
    }
    while (_rodRoundness.length > _numRods) {
      _rodRoundness.removeLast();
    }

    while (_mainWithinA.length < _numMains) {
      _mainWithinA.add(null);
    }
    while (_mainWithinA.length > _numMains) {
      _mainWithinA.removeLast();
    }
    while (_mainWithinB.length < _numMains) {
      _mainWithinB.add(null);
    }
    while (_mainWithinB.length > _numMains) {
      _mainWithinB.removeLast();
    }

    while (_rodWithinA.length < _numRods) {
      _rodWithinA.add(null);
    }
    while (_rodWithinA.length > _numRods) {
      _rodWithinA.removeLast();
    }
    while (_rodWithinB.length < _numRods) {
      _rodWithinB.add(null);
    }
    while (_rodWithinB.length > _numRods) {
      _rodWithinB.removeLast();
    }
  }

  void _setMains(int n) {
    setState(() {
      _numMains = n.clamp(1, 10);
      _numMainsCtrl.text = '$_numMains';
      _resizeLists();
      _clearResults();
    });
  }

  void _setRods(int n) {
    setState(() {
      _numRods = n.clamp(1, 16);
      _numRodsCtrl.text = '$_numRods';
      _resizeLists();
      _clearResults();
    });
  }

  void _clearResults() {
    setState(() {
      for (int i = 0; i < _mainRoundness.length; i++) {
        _mainRoundness[i] = null;
      }
      for (int i = 0; i < _rodRoundness.length; i++) {
        _rodRoundness[i] = null;
      }
      for (int i = 0; i < _mainWithinA.length; i++) {
        _mainWithinA[i] = null;
      }
      for (int i = 0; i < _mainWithinB.length; i++) {
        _mainWithinB[i] = null;
      }
      for (int i = 0; i < _rodWithinA.length; i++) {
        _rodWithinA[i] = null;
      }
      for (int i = 0; i < _rodWithinB.length; i++) {
        _rodWithinB[i] = null;
      }
    });
  }

  double? _p(TextEditingController c) => double.tryParse(c.text.trim());

  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }

  void _calculate() {
    _clearResults();

    final mainMin = _limitsEnabled ? _p(_mainMinCtrl) : null;
    final mainMax = _limitsEnabled ? _p(_mainMaxCtrl) : null;
    final rodMin = _limitsEnabled ? _p(_rodMinCtrl) : null;
    final rodMax = _limitsEnabled ? _p(_rodMaxCtrl) : null;

    setState(() {
      if (_crossSections) {
        for (int i = 0; i < _numMains; i++) {
          final a = _p(_mainA[i]);
          final b = _p(_mainB[i]);
          _mainRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
        }
        for (int i = 0; i < _numRods; i++) {
          final a = _p(_rodA[i]);
          final b = _p(_rodB[i]);
          _rodRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
        }
      }

      if (_limitsEnabled) {
        for (int i = 0; i < _numMains; i++) {
          final a = _p(_mainA[i]);
          _mainWithinA[i] = _within(a, mainMin, mainMax);
          if (_crossSections) {
            final b = _p(_mainB[i]);
            _mainWithinB[i] = _within(b, mainMin, mainMax);
          } else {
            _mainWithinB[i] = null;
          }
        }
        for (int i = 0; i < _numRods; i++) {
          final a = _p(_rodA[i]);
          _rodWithinA[i] = _within(a, rodMin, rodMax);
          if (_crossSections) {
            final b = _p(_rodB[i]);
            _rodWithinB[i] = _within(b, rodMin, rodMax);
          } else {
            _rodWithinB[i] = null;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _resizeLists(); // keep arrays sized safely
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header / options
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Crankshaft Measurements',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Units: use the same units throughout (in or mm).',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              // Counts
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numMainsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Main Journals',
                      helperText: '1–10',
                    ),
                    onChanged: (v) => _setMains(int.tryParse(v) ?? _numMains),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setMains(_numMains - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setMains(_numMains + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numRodsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Rod Journals',
                      helperText: '1–16',
                    ),
                    onChanged: (v) => _setRods(int.tryParse(v) ?? _numRods),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setRods(_numRods - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setRods(_numRods + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Enable A/B @ ~90° and compute |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() {
                  _crossSections = v;
                  _clearResults();
                }),
              ),

              SwitchListTile(
                title: const Text('Check against manufacturer limits'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() {
                  _limitsEnabled = v;
                  _clearResults();
                }),
              ),
              if (_limitsEnabled) ...[
                Row(children: [
                  Expanded(child: NumField(controller: _mainMinCtrl, label: 'Main Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _mainMaxCtrl, label: 'Main Max')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: NumField(controller: _rodMinCtrl, label: 'Rod Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _rodMaxCtrl, label: 'Rod Max')),
                ]),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: Text(_crossSections
                      ? (_limitsEnabled
                          ? 'Calculate Roundness & Limits'
                          : 'Calculate Roundness')
                      : (_limitsEnabled ? 'Calculate Limits' : 'Calculate')),
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Main journals
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Main Journals',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numMains, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? TwoFieldRow(
                            label: 'Main ${i + 1}',
                            aCtrl: _mainA[i],
                            bCtrl: _mainB[i],
                            roundness: _mainRoundness[i],
                            withinA: _mainWithinA[i],
                            withinB: _mainWithinB[i],
                          )
                        : SingleFieldRow(
                            label: 'Main ${i + 1}',
                            controller: _mainA[i],
                            within: _mainWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Rod journals
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rod Journals',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numRods, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? TwoFieldRow(
                            label: 'Rod ${i + 1}',
                            aCtrl: _rodA[i],
                            bCtrl: _rodB[i],
                            roundness: _rodRoundness[i],
                            withinA: _rodWithinA[i],
                            withinB: _rodWithinB[i],
                          )
                        : SingleFieldRow(
                            label: 'Rod ${i + 1}',
                            controller: _rodA[i],
                            within: _rodWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        const NotesCard("""
Guidance:
• Enter all diameters using the same unit (in or mm).
• Cross-section A/B are taken ~90° apart; roundness = |A − B|.
• Limits: if enabled, each reading (A/B or single) is checked against min/max.
• If min > max, the check is skipped (invalid limits).
"""),
      ],
    );
  }
}