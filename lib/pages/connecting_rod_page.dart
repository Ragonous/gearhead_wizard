import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

class ConnectingRodPage extends StatefulWidget {
  const ConnectingRodPage({super.key});
  @override
  State<ConnectingRodPage> createState() => _ConnectingRodPageState();
}

class _ConnectingRodPageState extends State<ConnectingRodPage> {
  // Count
  int _numRods = 8;
  final _numRodsCtrl = TextEditingController(text: '8');

  // Cross-section & limits toggles
  bool _crossSections = false;
  bool _limitsEnabled = false;

  // Limits (min/max) for big-end & pin-end
  final _bigMinCtrl = TextEditingController();
  final _bigMaxCtrl = TextEditingController();
  final _pinMinCtrl = TextEditingController();
  final _pinMaxCtrl = TextEditingController();

  // Measurements (A/B when cross-sections enabled)
  final List<TextEditingController> _bigA = [];
  final List<TextEditingController> _bigB = [];
  final List<TextEditingController> _pinA = [];
  final List<TextEditingController> _pinB = [];

  // Roundness results
  final List<double?> _bigRound = [];
  final List<double?> _pinRound = [];

  // OK/OUT flags for limit checks (per reading)
  final List<bool?> _bigWithinA = [];
  final List<bool?> _bigWithinB = [];
  final List<bool?> _pinWithinA = [];
  final List<bool?> _pinWithinB = [];

  @override
  void initState() {
    super.initState();
    _resizeLists();
  }

  @override
  void dispose() {
    _numRodsCtrl.dispose();
    _bigMinCtrl.dispose();
    _bigMaxCtrl.dispose();
    _pinMinCtrl.dispose();
    _pinMaxCtrl.dispose();
    for (final c in _bigA) {
      c.dispose();
    }
    for (final c in _bigB) {
      c.dispose();
    }
    for (final c in _pinA) {
      c.dispose();
    }
    for (final c in _pinB) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- sizing + housekeeping ----------
  void _resizeLists() {
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

    grow(_bigA, _numRods);
    grow(_bigB, _numRods);
    grow(_pinA, _numRods);
    grow(_pinB, _numRods);
    shrink(_bigA, _numRods);
    shrink(_bigB, _numRods);
    shrink(_pinA, _numRods);
    shrink(_pinB, _numRods);

    while (_bigRound.length < _numRods) {
      _bigRound.add(null);
    }
    while (_bigRound.length > _numRods) {
      _bigRound.removeLast();
    }
    while (_pinRound.length < _numRods) {
      _pinRound.add(null);
    }
    while (_pinRound.length > _numRods) {
      _pinRound.removeLast();
    }

    while (_bigWithinA.length < _numRods) {
      _bigWithinA.add(null);
    }
    while (_bigWithinA.length > _numRods) {
      _bigWithinA.removeLast();
    }
    while (_bigWithinB.length < _numRods) {
      _bigWithinB.add(null);
    }
    while (_bigWithinB.length > _numRods) {
      _bigWithinB.removeLast();
    }

    while (_pinWithinA.length < _numRods) {
      _pinWithinA.add(null);
    }
    while (_pinWithinA.length > _numRods) {
      _pinWithinA.removeLast();
    }
    while (_pinWithinB.length < _numRods) {
      _pinWithinB.add(null);
    }
    while (_pinWithinB.length > _numRods) {
      _pinWithinB.removeLast();
    }
  }

  void _setCount(int n) {
    setState(() {
      _numRods = n.clamp(1, 16);
      _numRodsCtrl.text = '$_numRods';
      _resizeLists();
      _clearResults();
    });
  }

  void _clearResults() {
    setState(() {
      for (int i = 0; i < _numRods; i++) {
        _bigRound[i] = null;
        _pinRound[i] = null;
        _bigWithinA[i] = null;
        _bigWithinB[i] = null;
        _pinWithinA[i] = null;
        _pinWithinB[i] = null;
      }
    });
  }

  // ---------- calc helpers ----------
  double? _p(TextEditingController c) => double.tryParse(c.text.trim());
  bool? _within(double? v, double? min, double? max) {
    if (v == null || min == null || max == null) return null;
    if (min > max) return null;
    return v >= min && v <= max;
  }

  void _calculate() {
    _clearResults();

    // Parse limits if enabled
    final bigMin = _limitsEnabled ? _p(_bigMinCtrl) : null;
    final bigMax = _limitsEnabled ? _p(_bigMaxCtrl) : null;
    final pinMin = _limitsEnabled ? _p(_pinMinCtrl) : null;
    final pinMax = _limitsEnabled ? _p(_pinMaxCtrl) : null;

    setState(() {
      // Roundness (A/B) if cross-sections enabled
      if (_crossSections) {
        for (int i = 0; i < _numRods; i++) {
          final aB = _p(_bigA[i]);
          final bB = _p(_bigB[i]);
          _bigRound[i] = (aB != null && bB != null) ? (aB - bB).abs() : null;

          final aP = _p(_pinA[i]);
          final bP = _p(_pinB[i]);
          _pinRound[i] = (aP != null && bP != null) ? (aP - bP).abs() : null;
        }
      }

      // Limit checks
      if (_limitsEnabled) {
        for (int i = 0; i < _numRods; i++) {
          final aB = _p(_bigA[i]);
          _bigWithinA[i] = _within(aB, bigMin, bigMax);

          final aP = _p(_pinA[i]);
          _pinWithinA[i] = _within(aP, pinMin, pinMax);

          if (_crossSections) {
            final bB = _p(_bigB[i]);
            _bigWithinB[i] = _within(bB, bigMin, bigMax);

            final bP = _p(_pinB[i]);
            _pinWithinB[i] = _within(bP, pinMin, pinMax);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _resizeLists(); // keep arrays sized before building
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
              const Text('Connecting Rod Bore Measurements',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                  'Use consistent units (in or mm). Bores measured with a bore gauge.',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numRodsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of Rods',
                      helperText: '1–16',
                    ),
                    onChanged: (v) => _setCount(int.tryParse(v) ?? _numRods),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setCount(_numRods - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setCount(_numRods + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle:
                    const Text('Record A/B ~90° apart; roundness = |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() {
                  _crossSections = v;
                  _clearResults();
                }),
              ),
              SwitchListTile(
                title: const Text('Check against manufacturer min/max'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() {
                  _limitsEnabled = v;
                  _clearResults();
                }),
              ),
              if (_limitsEnabled) ...[
                Row(children: [
                  Expanded(child: NumField(controller: _bigMinCtrl, label: 'Big-End Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _bigMaxCtrl, label: 'Big-End Max')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: NumField(controller: _pinMinCtrl, label: 'Pin-End Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _pinMaxCtrl, label: 'Pin-End Max')),
                ]),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Big-end bore section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Big-End Bore (crank end)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    _numRods,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _crossSections
                              ? TwoFieldRow(
                                  label: 'Rod ${i + 1}',
                                  aCtrl: _bigA[i],
                                  bCtrl: _bigB[i],
                                  roundness: _bigRound[i],
                                  withinA: _bigWithinA[i],
                                  withinB: _bigWithinB[i],
                                )
                              : SingleFieldRow(
                                  label: 'Rod ${i + 1}',
                                  controller: _bigA[i],
                                  within: _bigWithinA[i],
                                ),
                        )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Pin-end bore section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pin-End Bore (wrist pin)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    _numRods,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _crossSections
                              ? TwoFieldRow(
                                  label: 'Rod ${i + 1}',
                                  aCtrl: _pinA[i],
                                  bCtrl: _pinB[i],
                                  roundness: _pinRound[i],
                                  withinA: _pinWithinA[i],
                                  withinB: _pinWithinB[i],
                                )
                              : SingleFieldRow(
                                  label: 'Rod ${i + 1}',
                                  controller: _pinA[i],
                                  within: _pinWithinA[i],
                                ),
                        )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        const NotesCard("""
Notes:
• Enter all diameters using the same unit (in or mm).
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• If min > max, that limit set is treated as invalid and skipped.
"""),
      ],
    );
  }
}