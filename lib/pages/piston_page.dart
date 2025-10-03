import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

class PistonPage extends StatefulWidget {
  const PistonPage({super.key});
  @override
  State<PistonPage> createState() => _PistonPageState();
}

class _PistonPageState extends State<PistonPage> {
  int _numPistons = 8;
  final _numCtrl = TextEditingController(text: '8');

  bool _crossSections = false;
  bool _limitsEnabled = false;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  final List<TextEditingController> _pistonA = [];
  final List<TextEditingController> _pistonB = [];

  final List<double?> _roundness = [];
  final List<bool?> _withinA = [];
  final List<bool?> _withinB = [];

  @override
  void initState() {
    super.initState();
    _resizeLists();
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    for (final c in _pistonA) {
      c.dispose();
    }
    for (final c in _pistonB) {
      c.dispose();
    }
    super.dispose();
  }

  void _resizeLists() {
    _numPistons = _numPistons.clamp(1, 16);

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

    grow(_pistonA, _numPistons);
    grow(_pistonB, _numPistons);
    shrink(_pistonA, _numPistons);
    shrink(_pistonB, _numPistons);

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

  void _setCount(int n) {
    setState(() {
      _numPistons = n.clamp(1, 16);
      _numCtrl.text = '$_numPistons';
      _resizeLists();
      _clearResults();
    });
  }

  void _clearResults() {
    setState(() {
      for (int i = 0; i < _numPistons; i++) {
        _roundness[i] = null;
        _withinA[i] = null;
        _withinB[i] = null;
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
    final min = _limitsEnabled ? _p(_minCtrl) : null;
    final max = _limitsEnabled ? _p(_maxCtrl) : null;

    setState(() {
      for (int i = 0; i < _numPistons; i++) {
        final a = _p(_pistonA[i]);
        final b = _p(_pistonB[i]);

        if (_crossSections) {
          _roundness[i] = (a != null && b != null) ? (a - b).abs() : null;
        }
        if (_limitsEnabled) {
          _withinA[i] = _within(a, min, max);
          if (_crossSections) {
            _withinB[i] = _within(b, min, max);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _resizeLists();
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Piston Measurements',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Use consistent units (in or mm).',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of Pistons',
                      helperText: '1–16',
                    ),
                    onChanged: (v) => _setCount(int.tryParse(v) ?? _numPistons),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => _setCount(_numPistons - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => _setCount(_numPistons + 1),
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
              if (_limitsEnabled)
                Row(children: [
                  Expanded(child: NumField(controller: _minCtrl, label: 'Piston Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _maxCtrl, label: 'Piston Max')),
                ]),

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

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Piston Diameters',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    _numPistons,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _crossSections
                              ? TwoFieldRow(
                                  label: 'Piston ${i + 1}',
                                  aCtrl: _pistonA[i],
                                  bCtrl: _pistonB[i],
                                  roundness: _roundness[i],
                                  withinA: _withinA[i],
                                  withinB: _withinB[i],
                                )
                              : SingleFieldRow(
                                  label: 'Piston ${i + 1}',
                                  controller: _pistonA[i],
                                  within: _withinA[i],
                                ),
                        )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        const NotesCard("""
Notes:
• Enter piston diameters using the same unit (in or mm).
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• If min > max, the limit set is treated as invalid and skipped.
"""),
      ],
    );
  }
}