import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/gear_ratio_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/ui_helpers.dart';

class GearRatioCalculatorPage extends StatefulWidget {
  const GearRatioCalculatorPage({super.key});
  @override
  State<GearRatioCalculatorPage> createState() =>
      _GearRatioCalculatorPageState();
}

class _GearRatioCalculatorPageState extends State<GearRatioCalculatorPage> {
  // --- LOCAL UI CONTROLLERS ---
  final _tireDiaCtrl = TextEditingController();
  final _tireMetricCtrl = TextEditingController();
  final _axleRatioCtrl = TextEditingController();
  final _numGearsCtrl = TextEditingController();
  final List<TextEditingController> _gearCtrls = []; // Managed in sync
  final _tcaseHighCtrl = TextEditingController();
  final _tcaseLowCtrl = TextEditingController();
  final _splitterRatioCtrl = TextEditingController();
  final _mphCtrl = TextEditingController();
  final _rpmCtrl = TextEditingController();
  // --- END OF CONTROLLERS ---

  @override
  void initState() {
    super.initState();
    final provider = context.read<GearRatioProvider>();

    // Set initial text for simple controllers
    _tireDiaCtrl.text = provider.tireDia;
    _tireMetricCtrl.text = provider.tireMetric;
    _axleRatioCtrl.text = provider.axleRatio;
    _numGearsCtrl.text = provider.numGears.toString();
    _tcaseHighCtrl.text = provider.tcaseHigh;
    _tcaseLowCtrl.text = provider.tcaseLow;
    _splitterRatioCtrl.text = provider.splitterRatio;
    _mphCtrl.text = provider.mph;
    _rpmCtrl.text = provider.rpm;

    // Add listeners to update provider when text changes
    _tireDiaCtrl.addListener(() {
      context.read<GearRatioProvider>().updateTireDia(_tireDiaCtrl.text);
    });
    _tireMetricCtrl.addListener(() {
      context.read<GearRatioProvider>().updateTireMetric(_tireMetricCtrl.text);
    });
    _axleRatioCtrl.addListener(() {
      context.read<GearRatioProvider>().updateAxleRatio(_axleRatioCtrl.text);
    });
     _tcaseHighCtrl.addListener(() {
      context.read<GearRatioProvider>().updateTcaseHigh(_tcaseHighCtrl.text);
    });
     _tcaseLowCtrl.addListener(() {
      context.read<GearRatioProvider>().updateTcaseLow(_tcaseLowCtrl.text);
    });
    _splitterRatioCtrl.addListener(() {
      context.read<GearRatioProvider>().updateSplitterRatio(_splitterRatioCtrl.text);
    });
    _mphCtrl.addListener(() {
      context.read<GearRatioProvider>().updateMph(_mphCtrl.text);
    });
    _rpmCtrl.addListener(() {
      context.read<GearRatioProvider>().updateRpm(_rpmCtrl.text);
    });


    // Initial fill of gear ratio controllers
    _syncGearControllers(provider);
  }

  @override
  void dispose() {
    _tireDiaCtrl.dispose();
    _tireMetricCtrl.dispose();
    _axleRatioCtrl.dispose();
    _numGearsCtrl.dispose();
    for (final c in _gearCtrls) c.dispose();
    _tcaseHighCtrl.dispose();
    _tcaseLowCtrl.dispose();
    _splitterRatioCtrl.dispose();
    _mphCtrl.dispose();
    _rpmCtrl.dispose();
    super.dispose();
  }

  // Helper to sync the gear ratio controller list
  void _syncGearControllers(GearRatioProvider provider) {
    // Grow
    while (_gearCtrls.length < provider.numGears) {
      final index = _gearCtrls.length;
      final text = provider.gearRatios[index];
      final ctrl = TextEditingController(text: text);
      ctrl.addListener(() {
        context.read<GearRatioProvider>().updateGearRatio(index, ctrl.text);
      });
      _gearCtrls.add(ctrl);
    }
    // Shrink
    while (_gearCtrls.length > provider.numGears) {
      final ctrl = _gearCtrls.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    }
  }

  void _runCalcRpm(BuildContext context) {
    final provider = context.read<GearRatioProvider>();
    final error = provider.calcRpmAtMph();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _runCalcMph(BuildContext context) {
    final provider = context.read<GearRatioProvider>();
    final error = provider.calcMphAtRpm();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // Copied responsive helpers directly from original file
  Widget _responsiveChipRow({
    required String label,
    required List<Widget> chips,
  }) {
     return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: chips),
            ],
          );
        }
        return Row(
           children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            ...chips.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)),
          ],
        );
      },
    );
  }

  Widget _responsiveNumGearsRow(GearRatioProvider provider) {
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
                onChanged: (v) => provider.setNumGears(int.tryParse(v) ?? provider.numGears),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => provider.setNumGears(provider.numGears - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    onPressed: () => provider.setNumGears(provider.numGears + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          );
        }
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
              onChanged: (v) => provider.setNumGears(int.tryParse(v) ?? provider.numGears),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => provider.setNumGears(provider.numGears - 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            onPressed: () => provider.setNumGears(provider.numGears + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ]);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GearRatioProvider>();

    // Sync controllers on build
    _syncGearControllers(provider);
    if (_numGearsCtrl.text != provider.numGears.toString()) {
       _numGearsCtrl.text = provider.numGears.toString();
    }

    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle Setup
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Vehicle Setup', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              _responsiveChipRow(
                label: 'Tire Input:',
                chips: [
                  ChoiceChip(
                    label: const Text('Inches'),
                    selected: !provider.useMetricTires,
                    onSelected: (_) => provider.setUseMetricTires(false),
                  ),
                  ChoiceChip(
                    label: const Text('Metric (e.g., 275/40R18)'),
                    selected: provider.useMetricTires,
                    onSelected: (_) => provider.setUseMetricTires(true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (!provider.useMetricTires)
                NumField(controller: _tireDiaCtrl, label: 'Tire Diameter (in)', helperText: 'Example: 26.0')
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
              NumField(controller: _axleRatioCtrl, label: 'Rear Axle / Final Drive', helperText: 'Example: 3.73'),

              const SizedBox(height: 12),
              Text('Drivetrain', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<DriveType>(
                segments: const [
                  ButtonSegment(value: DriveType.twoWD, label: Text('2WD')),
                  ButtonSegment(value: DriveType.fourWD, label: Text('4WD')),
                ],
                selected: {provider.drive},
                onSelectionChanged: (s) => provider.setDriveType(s.first),
              ),

              if (provider.drive == DriveType.fourWD) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: NumField(controller: _tcaseHighCtrl, label: 'T-Case High Ratio', helperText: 'Typical: 1.00')),
                  const SizedBox(width: 12),
                  Expanded(child: NumField(controller: _tcaseLowCtrl, label: 'T-Case Low Ratio', helperText: 'Typical: 2.72–4.00')),
                ]),
                const SizedBox(height: 12),
                _responsiveChipRow(
                  label: 'Range:',
                  chips: [
                    ChoiceChip(label: const Text('High'), selected: provider.range == 'High', onSelected: (_) => provider.setRange('High')),
                    ChoiceChip(label: const Text('Low'), selected: provider.range == 'Low', onSelected: (_) => provider.setRange('Low')),
                  ],
                ),
              ],

              const Divider(height: 24),

              SwitchListTile(
                title: const Text('Gear Splitter / GearVendors'),
                subtitle: const Text('Optional over/under-drive between trans and axle'),
                value: provider.splitterEnabled,
                onChanged: (v) => provider.setSplitterEnabled(v),
              ),
              if (provider.splitterEnabled) ...[
                NumField(controller: _splitterRatioCtrl, label: 'Splitter Ratio', helperText: 'Overdrive ~0.78; Underdrive > 1.0'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Splitter Engaged (On)'),
                  value: provider.splitterEngaged, // Read transient state
                  onChanged: (v) => provider.setSplitterEngaged(v ?? false), // Set transient state
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Transmission', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              Text('Type', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<TransType>(
                segments: const [
                  ButtonSegment(value: TransType.manual, label: Text('Manual')),
                  ButtonSegment(value: TransType.automatic, label: Text('Automatic')),
                ],
                selected: {provider.transType},
                onSelectionChanged: (s) => provider.setTransType(s.first),
              ),

              const SizedBox(height: 12),
              _responsiveNumGearsRow(provider),

              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    provider.numGears,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: KeyedSubtree( // Keep state when list changes
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Calculate', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              
              InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Selected Gear'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: provider.selectedGearIndex,
                    items: List.generate(provider.numGears, (i) => DropdownMenuItem(value: i, child: Text('Gear ${i + 1}'))),
                    onChanged: (v) => provider.setSelectedGearIndex(v ?? provider.selectedGearIndex),
                  ),
                ),
              ),
              if (provider.drive == DriveType.fourWD) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Use Range'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: provider.range,
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (v) => provider.setRange(v ?? 'High'),
                    ),
                  ),
                ),
              ],
              if (provider.splitterEnabled)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Splitter Engaged for Calc'),
                  value: provider.splitterEngaged, // Read transient state
                  onChanged: (v) => provider.setSplitterEngaged(v ?? false), // Set transient state
                ),

              // Info rows removed as they duplicate calculations in provider

              const SizedBox(height: 16),
              NumField(controller: _mphCtrl, label: 'Speed (mph) → RPM'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _runCalcRpm(context), // Use helper
                  icon: const Icon(Icons.speed),
                  label: const Text('Calculate RPM @ MPH'),
                ),
              ),
              const SizedBox(height: 8),
              _ResultRow('RPM @ Speed', provider.rpmAtMph),

              const Divider(height: 32),

              NumField(controller: _rpmCtrl, label: 'Engine Speed (RPM) → MPH'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _runCalcMph(context), // Use helper
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Calculate MPH @ RPM'),
                ),
              ),
              const SizedBox(height: 8),
              _ResultRow('MPH @ RPM', provider.mphAtRpm),
            ]),
          ),
        ),
      ],
    );
  }
}

// ResultRow and InfoRow copied from original file
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

// InfoRow removed as provider now handles effective final drive etc internally