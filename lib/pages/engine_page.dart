import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

class EnginePage extends StatefulWidget {
  const EnginePage({super.key});
  @override
  State<EnginePage> createState() => _EnginePageState();
}

class _EnginePageState extends State<EnginePage> {
  // Counts
  int _numMainBores = 5;
  int _numCylinders = 8;

  final _numMainBoresCtrl = TextEditingController(text: '5');
  final _numCylindersCtrl = TextEditingController(text: '8');

  // Cross-section & limits
  bool _crossSections = false;
  bool _limitsEnabled = false;

  // Limits: mains and cylinders separate
  final _mainMinCtrl = TextEditingController();
  final _mainMaxCtrl = TextEditingController();
  final _cylMinCtrl = TextEditingController();
  final _cylMaxCtrl = TextEditingController();

  // Measurements (A/B lists for cross-sections)
  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _cylA = [];
  final List<TextEditingController> _cylB = [];

  // Roundness results (when cross-sections enabled)
  final List<double?> _mainRoundness = [];
  final List<double?> _cylRoundness = [];

  // Limit checks
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _cylWithinA = [];
  final List<bool?> _cylWithinB = [];

  @override
  void initState() {
    super.initState();
    _resizeLists();
  }

  @override
  void dispose() {
    _numMainBoresCtrl.dispose();
    _numCylindersCtrl.dispose();
    _mainMinCtrl.dispose();
    _mainMaxCtrl.dispose();
    _cylMinCtrl.dispose();
    _cylMaxCtrl.dispose();
    for (final c in _mainA) {
      c.dispose();
    }
    for (final c in _mainB) {
      c.dispose();
    }
    for (final c in _cylA) {
      c.dispose();
    }
    for (final c in _cylB) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- sizing helpers ----------
  void _resizeLists() {
    _numMainBores = _numMainBores.clamp(1, 10);
    _numCylinders = _numCylinders.clamp(1, 16);

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

    grow(_mainA, _numMainBores);
    grow(_mainB, _numMainBores);
    grow(_cylA, _numCylinders);
    grow(_cylB, _numCylinders);
    shrink(_mainA, _numMainBores);
    shrink(_mainB, _numMainBores);
    shrink(_cylA, _numCylinders);
    shrink(_cylB, _numCylinders);

    while (_mainRoundness.length < _numMainBores) {
      _mainRoundness.add(null);
    }
    while (_mainRoundness.length > _numMainBores) {
      _mainRoundness.removeLast();
    }
    while (_cylRoundness.length < _numCylinders) {
      _cylRoundness.add(null);
    }
    while (_cylRoundness.length > _numCylinders) {
      _cylRoundness.removeLast();
    }

    while (_mainWithinA.length < _numMainBores) {
      _mainWithinA.add(null);
    }
    while (_mainWithinA.length > _numMainBores) {
      _mainWithinA.removeLast();
    }
    while (_mainWithinB.length < _numMainBores) {
      _mainWithinB.add(null);
    }
    while (_mainWithinB.length > _numMainBores) {
      _mainWithinB.removeLast();
    }

    while (_cylWithinA.length < _numCylinders) {
      _cylWithinA.add(null);
    }
    while (_cylWithinA.length > _numCylinders) {
      _cylWithinA.removeLast();
    }
    while (_cylWithinB.length < _numCylinders) {
      _cylWithinB.add(null);
    }
    while (_cylWithinB.length > _numCylinders) {
      _cylWithinB.removeLast();
    }
  }

  void _setMains(int n) {
    setState(() {
      _numMainBores = n.clamp(1, 10);
      _numMainBoresCtrl.text = '$_numMainBores';
      _resizeLists();
      _clearResults();
    });
  }

  void _setCyls(int n) {
    setState(() {
      _numCylinders = n.clamp(1, 16);
      _numCylindersCtrl.text = '$_numCylinders';
      _resizeLists();
      _clearResults();
    });
  }

  void _clearResults() {
    setState(() {
      for (int i = 0; i < _mainRoundness.length; i++) {
        _mainRoundness[i] = null;
      }
      for (int i = 0; i < _cylRoundness.length; i++) {
        _cylRoundness[i] = null;
      }
      for (int i = 0; i < _mainWithinA.length; i++) {
        _mainWithinA[i] = null;
      }
      for (int i = 0; i < _mainWithinB.length; i++) {
        _mainWithinB[i] = null;
      }
      for (int i = 0; i < _cylWithinA.length; i++) {
        _cylWithinA[i] = null;
      }
      for (int i = 0; i < _cylWithinB.length; i++) {
        _cylWithinB[i] = null;
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
    final cylMin = _limitsEnabled ? _p(_cylMinCtrl) : null;
    final cylMax = _limitsEnabled ? _p(_cylMaxCtrl) : null;

    setState(() {
      if (_crossSections) {
        for (int i = 0; i < _numMainBores; i++) {
          final a = _p(_mainA[i]);
          final b = _p(_mainB[i]);
          _mainRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
        }
        for (int i = 0; i < _numCylinders; i++) {
          final a = _p(_cylA[i]);
          final b = _p(_cylB[i]);
          _cylRoundness[i] = (a != null && b != null) ? (a - b).abs() : null;
        }
      }

      if (_limitsEnabled) {
        for (int i = 0; i < _numMainBores; i++) {
          final a = _p(_mainA[i]);
          _mainWithinA[i] = _within(a, mainMin, mainMax);
          if (_crossSections) {
            final b = _p(_mainB[i]);
            _mainWithinB[i] = _within(b, mainMin, mainMax);
          } else {
            _mainWithinB[i] = null;
          }
        }
        for (int i = 0; i < _numCylinders; i++) {
          final a = _p(_cylA[i]);
          _cylWithinA[i] = _within(a, cylMin, cylMax);
          if (_crossSections) {
            final b = _p(_cylB[i]);
            _cylWithinB[i] = _within(b, cylMin, cylMax);
          } else {
            _cylWithinB[i] = null;
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
              const Text('Engine Measurements',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                  'Use consistent units (in or mm). Enter bore diameters measured with a bore gauge.',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              // Counts
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numMainBoresCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Main Housing Bores',
                      helperText: '1–10',
                    ),
                    onChanged: (v) =>
                        _setMains(int.tryParse(v) ?? _numMainBores),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setMains(_numMainBores - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setMains(_numMainBores + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numCylindersCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Cylinders',
                      helperText: '1–16',
                    ),
                    onChanged: (v) =>
                        _setCyls(int.tryParse(v) ?? _numCylinders),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setCyls(_numCylinders - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setCyls(_numCylinders + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle:
                    const Text('Record A/B ~90° apart and compute |A − B|'),
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
                  Expanded(
                      child: NumField(controller: _cylMinCtrl, label: 'Cylinder Min')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: NumField(controller: _cylMaxCtrl, label: 'Cylinder Max')),
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

        // Main bores
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Main Housing Bores',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numMainBores, (i) {
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

        // Cylinders
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cylinder Bores',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numCylinders, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? TwoFieldRow(
                            label: 'Cylinder ${i + 1}',
                            aCtrl: _cylA[i],
                            bCtrl: _cylB[i],
                            roundness: _cylRoundness[i],
                            withinA: _cylWithinA[i],
                            withinB: _cylWithinB[i],
                          )
                        : SingleFieldRow(
                            label: 'Cylinder ${i + 1}',
                            controller: _cylA[i],
                            within: _cylWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        const NotesCard("""
Notes:
• Use the same units (in or mm) everywhere.
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• Limits are checked per reading (A/B or single) against min/max for mains and cylinders separately.
• If min > max, that limit set is treated as invalid and skipped.
"""),
      ],
    );
  }
}