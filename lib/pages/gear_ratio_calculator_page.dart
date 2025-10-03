import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

enum TransType { manual, automatic }

enum DriveType { twoWD, fourWD }

class GearRatioCalculatorPage extends StatefulWidget {
  const GearRatioCalculatorPage({super.key});
  @override
  State<GearRatioCalculatorPage> createState() =>
      _GearRatioCalculatorPageState();
}

class _GearRatioCalculatorPageState extends State<GearRatioCalculatorPage> {
  // Tire input
  bool _useMetricTires = false;
  final _tireDiaCtrl = TextEditingController(text: '26.0'); // inches
  final _tireMetricCtrl =
      TextEditingController(text: '275/40R18'); // metric code

  // Driveline basics
  final _axleRatioCtrl = TextEditingController(text: '3.73');

  // Transmission
  TransType _transType = TransType.manual;
  int _numGears = 5; // 1..10
  final _numGearsCtrl = TextEditingController(text: '5');
  final List<TextEditingController> _gearCtrls = List.generate(
    5,
    (i) => TextEditingController(
      text: switch (i) {
        0 => '2.95',
        1 => '1.94',
        2 => '1.34',
        3 => '1.00',
        4 => '0.73',
        _ => ''
      },
    ),
  );

  // Drivetrain
  DriveType _drive = DriveType.twoWD;
  final _tcaseHighCtrl = TextEditingController(text: '1.00');
  final _tcaseLowCtrl = TextEditingController(text: '2.72');
  String _range = 'High'; // High | Low

  // Splitter / GearVendors
  bool _splitterEnabled = false;
  final _splitterRatioCtrl =
      TextEditingController(text: '0.78'); // overdrive example
  bool _splitterEngaged = false;

  // Calculations
  final _mphCtrl = TextEditingController(text: '65');
  final _rpmCtrl = TextEditingController(text: '2500');
  int _selectedGearIndex = 3; // default to 4th

  double? _rpmAtMph;
  double? _mphAtRpm;

  @override
  void dispose() {
    _tireDiaCtrl.dispose();
    _tireMetricCtrl.dispose();
    _axleRatioCtrl.dispose();
    _numGearsCtrl.dispose();
    for (final c in _gearCtrls) {
      c.dispose();
    }
    _tcaseHighCtrl.dispose();
    _tcaseLowCtrl.dispose();
    _splitterRatioCtrl.dispose();
    _mphCtrl.dispose();
    _rpmCtrl.dispose();
    super.dispose();
  }

  // --- logic helpers ---
  double? _parse(TextEditingController c) => double.tryParse(c.text.trim());

  double _getTireDiameterInches() {
    if (!_useMetricTires) return _parse(_tireDiaCtrl) ?? 0;
    return _parseMetricTire(_tireMetricCtrl.text.trim());
  }

  double _parseMetricTire(String s) {
    final m =
        RegExp(r'(\d{3})/(\d{2})R(\d{2})', caseSensitive: false).firstMatch(s);
    if (m == null) return 0;
    final width = double.parse(m.group(1)!); // mm
    final aspect = double.parse(m.group(2)!); // %
    final rimIn = double.parse(m.group(3)!); // inches
    final sidewallMm = width * (aspect / 100.0);
    final diameterMm = 2 * sidewallMm + rimIn * 25.4;
    return diameterMm / 25.4;
  }

  void _setNumGears(int n) {
    final clamped = n.clamp(1, 10);
    if (clamped == _numGears) return;

    setState(() {
      // grow
      while (_gearCtrls.length < clamped) {
        _gearCtrls.add(TextEditingController());
      }
      // shrink
      while (_gearCtrls.length > clamped) {
        _gearCtrls.removeLast().dispose();
      }
      _numGears = clamped;

      if (_selectedGearIndex >= _numGears) {
        _selectedGearIndex = _numGears - 1;
      }

      _numGearsCtrl.text = '$_numGears';
    });
  }

  double _effectiveFinalDrive() {
    final axle = _parse(_axleRatioCtrl) ?? 0;
    final tHigh = _parse(_tcaseHighCtrl) ?? 1.0;
    final tLow = _parse(_tcaseLowCtrl) ?? 1.0;
    final tCase =
        (_drive == DriveType.fourWD) ? (_range == 'Low' ? tLow : tHigh) : 1.0;
    final split = (_splitterEnabled && _splitterEngaged)
        ? (_parse(_splitterRatioCtrl) ?? 1.0)
        : 1.0;
    return axle * tCase * split;
  }

  double _selectedGearRatio() {
    final idx = _selectedGearIndex.clamp(0, _numGears - 1);
    final g = double.tryParse(_gearCtrls[idx].text.trim());
    return (g == null || g <= 0) ? 1.0 : g;
  }

  void _calcRpmAtMph() {
    final d = _getTireDiameterInches();
    final mph = _parse(_mphCtrl);
    if (d <= 0 || mph == null || mph < 0) {
      return _snack('Enter valid tire and MPH.');
    }
    final rpm = (mph * _selectedGearRatio() * _effectiveFinalDrive() * 336.0) / d;
    setState(() => _rpmAtMph = rpm);
  }

  void _calcMphAtRpm() {
    final d = _getTireDiameterInches();
    final rpm = _parse(_rpmCtrl);
    if (d <= 0 || rpm == null || rpm < 0) {
      return _snack('Enter valid tire and RPM.');
    }
    final mph = (rpm * d) / (_selectedGearRatio() * _effectiveFinalDrive() * 336.0);
    setState(() => _mphAtRpm = mph);
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---------- responsive helpers ----------
  Widget _responsiveChipRow({
    required String label,
    required List<Widget> chips,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420; // tweak as needed
        if (narrow) {
          // Stack label above; chips wrap
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: chips,
              ),
            ],
          );
        }
        // Wide screens: keep row
        return Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            ...chips
                .map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)),
          ],
        );
      },
    );
  }

  Widget _responsiveNumGearsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _numGearsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of Gears',
                  helperText: '1–10',
                ),
                onChanged: (v) => _setNumGears(int.tryParse(v) ?? _numGears),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _setNumGears(_numGears - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    onPressed: () => _setNumGears(_numGears + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          );
        }
        // Wide: one row
        return Row(children: [
          Expanded(
            child: TextField(
              controller: _numGearsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Number of Gears',
                helperText: '1–10',
              ),
              onChanged: (v) => _setNumGears(int.tryParse(v) ?? _numGears),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _setNumGears(_numGears - 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            onPressed: () => _setNumGears(_numGears + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle Setup
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Vehicle Setup',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              // Tire input toggle (responsive)
              _responsiveChipRow(
                label: 'Tire Input:',
                chips: [
                  ChoiceChip(
                    label: const Text('Inches'),
                    selected: !_useMetricTires,
                    onSelected: (_) => setState(() => _useMetricTires = false),
                  ),
                  ChoiceChip(
                    label: const Text('Metric (e.g., 275/40R18)'),
                    selected: _useMetricTires,
                    onSelected: (_) => setState(() => _useMetricTires = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (!_useMetricTires)
                NumField(
                    controller: _tireDiaCtrl,
                    label: 'Tire Diameter (in)',
                    helperText: 'Example: 26.0')
              else
                TextField(
                  controller: _tireMetricCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tire Size (metric)',
                    helperText: 'Format: Width/AspectRim, e.g. 275/40R18',
                  ),
                ),

              const SizedBox(height: 12),
              NumField(
                  controller: _axleRatioCtrl,
                  label: 'Rear Axle / Final Drive',
                  helperText: 'Example: 3.73'),

              const SizedBox(height: 12),
              // 2WD / 4WD toggle
              Text('Drivetrain',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<DriveType>(
                segments: const [
                  ButtonSegment(value: DriveType.twoWD, label: Text('2WD')),
                  ButtonSegment(value: DriveType.fourWD, label: Text('4WD')),
                ],
                selected: {_drive},
                onSelectionChanged: (s) => setState(() => _drive = s.first),
              ),

              if (_drive == DriveType.fourWD) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: NumField(
                          controller: _tcaseHighCtrl,
                          label: 'T-Case High Ratio',
                          helperText: 'Typical: 1.00')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumField(
                          controller: _tcaseLowCtrl,
                          label: 'T-Case Low Ratio',
                          helperText: 'Typical: 2.72–4.00')),
                ]),
                const SizedBox(height: 12),
                // Range chips (responsive)
                _responsiveChipRow(
                  label: 'Range:',
                  chips: [
                    ChoiceChip(
                      label: const Text('High'),
                      selected: _range == 'High',
                      onSelected: (_) => setState(() => _range = 'High'),
                    ),
                    ChoiceChip(
                      label: const Text('Low'),
                      selected: _range == 'Low',
                      onSelected: (_) => setState(() => _range = 'Low'),
                    ),
                  ],
                ),
              ],

              const Divider(height: 24),

              // Splitter toggle
              SwitchListTile(
                title: const Text('Gear Splitter / GearVendors'),
                subtitle: const Text(
                    'Optional over/under-drive between trans and axle'),
                value: _splitterEnabled,
                onChanged: (v) => setState(() => _splitterEnabled = v),
              ),
              if (_splitterEnabled) ...[
                NumField(
                    controller: _splitterRatioCtrl,
                    label: 'Splitter Ratio',
                    helperText: 'Overdrive ~0.78; Underdrive > 1.0'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Splitter Engaged (On)'),
                  value: _splitterEngaged,
                  onChanged: (v) =>
                      setState(() => _splitterEngaged = v ?? false),
                ),
              ],
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Transmission
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Transmission',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              // Manual / Automatic toggle
              Text('Type',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<TransType>(
                segments: const [
                  ButtonSegment(value: TransType.manual, label: Text('Manual')),
                  ButtonSegment(
                      value: TransType.automatic, label: Text('Automatic')),
                ],
                selected: {_transType},
                onSelectionChanged: (s) => setState(() => _transType = s.first),
              ),

              const SizedBox(height: 12),
              // # of gears (responsive)
              _responsiveNumGearsRow(),

              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    _numGears,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: KeyedSubtree(
                            key: ValueKey('gear-$i'),
                            child: NumField(
                                controller: _gearCtrls[i],
                                label: 'Gear ${i + 1} Ratio',
                                helperText: i == 0 ? 'e.g., 2.95' : null),
                          ),
                        )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Calculation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Calculate',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              // gear picker
              InputDecorator(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Selected Gear'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedGearIndex,
                    items: List.generate(
                        _numGears,
                        (i) => DropdownMenuItem(
                            value: i, child: Text('Gear ${i + 1}'))),
                    onChanged: (v) => setState(
                        () => _selectedGearIndex = v ?? _selectedGearIndex),
                  ),
                ),
              ),
              if (_drive == DriveType.fourWD) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Use Range'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _range,
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (v) => setState(() => _range = v ?? 'High'),
                    ),
                  ),
                ),
              ],
              if (_splitterEnabled)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Splitter Engaged for Calc'),
                  value: _splitterEngaged,
                  onChanged: (v) =>
                      setState(() => _splitterEngaged = v ?? false),
                ),

              const SizedBox(height: 12),
              _InfoRow('Effective Final Drive', _effectiveFinalDrive()),
              _InfoRow('Selected Gear Ratio', _selectedGearRatio()),

              const SizedBox(height: 16),
              NumField(controller: _mphCtrl, label: 'Speed (mph) → RPM'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calcRpmAtMph,
                  icon: const Icon(Icons.speed),
                  label: const Text('Calculate RPM @ MPH'),
                ),
              ),
              const SizedBox(height: 8),
              _ResultRow('RPM @ Speed', _rpmAtMph),

              const Divider(height: 32),

              NumField(controller: _rpmCtrl, label: 'Engine Speed (RPM) → MPH'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calcMphAtRpm,
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Calculate MPH @ RPM'),
                ),
              ),
              const SizedBox(height: 8),
              _ResultRow('MPH @ RPM', _mphAtRpm),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double? value;
  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value == null ? '—' : value!.toStringAsFixed(2)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final double value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value.toStringAsFixed(3)),
      ],
    );
  }
}