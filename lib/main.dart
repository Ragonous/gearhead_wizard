import 'package:flutter/material.dart';

void main() => runApp(const GearheadWizardApp());

class GearheadWizardApp extends StatelessWidget {
  const GearheadWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gearhead Wizard',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  final _pages = const [  // <--------------------------------------------------------------------------------------------FINAL PAGES
    HomePage(),
    TurboCalculatorPage(),
    GearRatioCalculatorPage(),
    CrankshaftPage(),
    EnginePage(),
    ConnectingRodPage(),
    PistonPage(),
  ];

//⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄FINAL TITLES
  final _titles = const ['Home', 'Turbo Calculator', 'Gear Ratio Calculator', 'Crankshaft', 'Engine', 'Connecting Rod', 'Piston'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gearhead Wizard',
                applicationVersion: '0.1.0',
                applicationIcon: const _AppIcon(size: 48),
                children: const [
                  SizedBox(height: 8),
                  Text('A growing toolkit for gearheads: boost, gearing, and more.'),
                ],
              );
            },
          )
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), label: 'Turbo'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Gears'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Crank'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_outlined), label: 'Engine'),
          NavigationDestination(icon: Icon(Icons.link_outlined), label: 'Rod'),
          NavigationDestination(icon: Icon(Icons.album_outlined), label: 'Piston'), 
        ],
      ),
    );
  }
}

/// ----------------------------- HOME PAGE ------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _AppIcon(size: 120),
            const SizedBox(height: 16),
            Text(
              'Gearhead Wizard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your pocket toolbox for boost, gearing, and more.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bolt_outlined,
                    title: 'Turbo',
                    subtitle: 'PR & est. HP',
                    onTap: () => _goToTab(context, 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.settings_outlined,
                    title: 'Gears',
                    subtitle: 'RPM ⇆ MPH',
                    onTap: () => _goToTab(context, 2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // “What’s inside” list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _ListLine(icon: Icons.check_circle_outline, text: 'Turbo calculator (pressure ratio, estimated HP)'),
                    _ListLine(icon: Icons.check_circle_outline, text: 'Gear ratio calculator (RPM @ speed & speed @ RPM)'),
                    _ListLine(icon: Icons.upcoming_outlined, text: 'Coming soon: Compression ratio, injector sizing, tire/speedo'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CTA row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _goToTab(context, 1),
                    icon: const Icon(Icons.bolt_outlined),
                    label: const Text('Open Turbo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _goToTab(context, 2),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Open Gears'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    // Use Navigator to pop and push, or use a callback/state management.
    // For this simple case, you can use a callback passed from RootScaffold.
    // Example: show a SnackBar indicating navigation (or implement a callback).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switch to tab $index (implement tab change logic)')),
    );
  }
}

/// Logo widget that uses your asset if present, otherwise a Flutter fallback
class _AppIcon extends StatelessWidget {
  final double size;
  const _AppIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 6),
      child: SizedBox(
        height: size,
        width: size,
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if you haven't added assets/logo.png yet
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: FlutterLogo(size: 72)),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ListLine({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// ----------------------------- TURBO CALC -------------------------------------------------------------------------------------------------------------------------------------------------------------------
class TurboCalculatorPage extends StatefulWidget {
  const TurboCalculatorPage({super.key});
  @override
  State<TurboCalculatorPage> createState() => _TurboCalculatorPageState();
}

class _TurboCalculatorPageState extends State<TurboCalculatorPage> {
  final _naHpCtrl = TextEditingController(text: '300');
  final _boostPsiCtrl = TextEditingController(text: '8');
  final _efficiencyCtrl = TextEditingController(text: '0.90');

  double? _pressureRatio;
  double? _boostedHp;

  @override
  void dispose() {
    _naHpCtrl.dispose();
    _boostPsiCtrl.dispose();
    _efficiencyCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final naHp = double.tryParse(_naHpCtrl.text.trim());
    final boostPsi = double.tryParse(_boostPsiCtrl.text.trim());
    final eff = double.tryParse(_efficiencyCtrl.text.trim());

    if (naHp == null || boostPsi == null || eff == null) {
      _snack('Please enter valid numbers.');
      return;
    }
    if (eff <= 0 || eff > 1.2) {
      _snack('Efficiency should be ~0.70–1.00 (try 0.85–0.95).');
      return;
    }

    final pr = (boostPsi + 14.7) / 14.7;
    final estHp = naHp * pr * eff;

    setState(() {
      _pressureRatio = pr;
      _boostedHp = estHp;
    });
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _num(_naHpCtrl, 'NA Horsepower (hp)'),
                  const SizedBox(height: 12),
                  _num(_boostPsiCtrl, 'Boost (psi)'),
                  const SizedBox(height: 12),
                  _num(_efficiencyCtrl, 'Efficiency (0.70–1.00)', helper: 'Default 0.90 for a healthy street setup'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_pressureRatio != null || _boostedHp != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Pressure Ratio', _pressureRatio),
                    const SizedBox(height: 8),
                    _row('Estimated Boosted HP', _boostedHp),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          _notes("""
• Quick estimate—real results depend on compressor match, AFR, timing, IAT/intercooler, and back-pressure.
• Rough turbo sizing: target airflow (lb/min) ≈ target HP / 10.
"""),
        ],
      ),
    );
  }

  Widget _num(TextEditingController c, String l, {String? helper}) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l, helperText: helper),
      );

  Widget _row(String l, double? v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(v == null ? '—' : v.toStringAsFixed(2)),
        ],
      );

  Widget _notes(String t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(t)));
}

/// --------------------------- GEAR RATIO CALC -------------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------- GEAR RATIO CALC (ADVANCED) --------------------------- Rev A2
// --------------------------- GEAR RATIO CALC (TOGGLE + DYNAMIC) --------------------------- Rev A3
// --------------------------- GEAR RATIO CALC (TOGGLES + FIXED GEAR COUNT) --------------------------- Rev A4
class GearRatioCalculatorPage extends StatefulWidget {
  const GearRatioCalculatorPage({super.key});
  @override
  State<GearRatioCalculatorPage> createState() => _GearRatioCalculatorPageState();
}

enum TransType { manual, automatic }
enum DriveType { twoWD, fourWD }

class _GearRatioCalculatorPageState extends State<GearRatioCalculatorPage> {
  // Tire input
  bool _useMetricTires = false;
  final _tireDiaCtrl = TextEditingController(text: '26.0');          // inches
  final _tireMetricCtrl = TextEditingController(text: '275/40R18');   // metric code

  // Driveline basics
  final _axleRatioCtrl = TextEditingController(text: '3.73');

  // Transmission
  TransType _transType = TransType.manual;
  int _numGears = 5; // 1..10
  final _numGearsCtrl = TextEditingController(text: '5');
  final List<TextEditingController> _gearCtrls = List.generate(
    5,
    (i) => TextEditingController(
      text: switch (i) { 0 => '2.95', 1 => '1.94', 2 => '1.34', 3 => '1.00', 4 => '0.73', _ => '' },
    ),
  );

  // Drivetrain
  DriveType _drive = DriveType.twoWD;
  final _tcaseHighCtrl = TextEditingController(text: '1.00');
  final _tcaseLowCtrl  = TextEditingController(text: '2.72');
  String _range = 'High'; // High | Low

  // Splitter / GearVendors
  bool _splitterEnabled = false;
  final _splitterRatioCtrl = TextEditingController(text: '0.78'); // overdrive example
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
    for (final c in _gearCtrls) { c.dispose(); }
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
    final m = RegExp(r'(\d{3})/(\d{2})R(\d{2})', caseSensitive: false).firstMatch(s);
    if (m == null) return 0;
    final width = double.parse(m.group(1)!);   // mm
    final aspect = double.parse(m.group(2)!);  // %
    final rimIn = double.parse(m.group(3)!);   // inches
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
    final tLow  = _parse(_tcaseLowCtrl)  ?? 1.0;
    final tCase = (_drive == DriveType.fourWD) ? (_range == 'Low' ? tLow : tHigh) : 1.0;
    final split = (_splitterEnabled && _splitterEngaged) ? (_parse(_splitterRatioCtrl) ?? 1.0) : 1.0;
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
    if (d <= 0 || mph == null || mph < 0) return _snack('Enter valid tire and MPH.');
    final rpm = (mph * _selectedGearRatio() * _effectiveFinalDrive() * 336.0) / d;
    setState(() => _rpmAtMph = rpm);
  }

  void _calcMphAtRpm() {
    final d = _getTireDiameterInches();
    final rpm = _parse(_rpmCtrl);
    if (d <= 0 || rpm == null || rpm < 0) return _snack('Enter valid tire and RPM.');
    final mph = (rpm * d) / (_selectedGearRatio() * _effectiveFinalDrive() * 336.0);
    setState(() => _mphAtRpm = mph);
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

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
            ...chips.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Vehicle Setup', style: TextStyle(fontWeight: FontWeight.w700)),
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
                _num(_tireDiaCtrl, 'Tire Diameter (in)', helper: 'Example: 26.0')
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
              _num(_axleRatioCtrl, 'Rear Axle / Final Drive', helper: 'Example: 3.73'),

              const SizedBox(height: 12),
              // 2WD / 4WD toggle
              Text('Drivetrain', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
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
                  Expanded(child: _num(_tcaseHighCtrl, 'T-Case High Ratio', helper: 'Typical: 1.00')),
                  const SizedBox(width: 12),
                  Expanded(child: _num(_tcaseLowCtrl, 'T-Case Low Ratio',  helper: 'Typical: 2.72–4.00')),
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
                subtitle: const Text('Optional over/under-drive between trans and axle'),
                value: _splitterEnabled,
                onChanged: (v) => setState(() => _splitterEnabled = v),
              ),
              if (_splitterEnabled) ...[
                _num(_splitterRatioCtrl, 'Splitter Ratio', helper: 'Overdrive ~0.78; Underdrive > 1.0'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Splitter Engaged (On)'),
                  value: _splitterEngaged,
                  onChanged: (v) => setState(() => _splitterEngaged = v ?? false),
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

              // Manual / Automatic toggle
              Text('Type', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<TransType>(
                segments: const [
                  ButtonSegment(value: TransType.manual, label: Text('Manual')),
                  ButtonSegment(value: TransType.automatic, label: Text('Automatic')),
                ],
                selected: {_transType},
                onSelectionChanged: (s) => setState(() => _transType = s.first),
              ),

              const SizedBox(height: 12),
              // # of gears (responsive)
              _responsiveNumGearsRow(),

              const SizedBox(height: 12),
              Column(
                children: List.generate(_numGears, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KeyedSubtree(
                    key: ValueKey('gear-$i'),
                    child: _num(_gearCtrls[i], 'Gear ${i + 1} Ratio', helper: i == 0 ? 'e.g., 2.95' : null),
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
              // gear picker
              InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Selected Gear'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedGearIndex,
                    items: List.generate(_numGears, (i) => DropdownMenuItem(value: i, child: Text('Gear ${i + 1}'))),
                    onChanged: (v) => setState(() => _selectedGearIndex = v ?? _selectedGearIndex),
                  ),
                ),
              ),
              if (_drive == DriveType.fourWD) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Use Range'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _range,
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(value: 'Low',  child: Text('Low')),
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
                  onChanged: (v) => setState(() => _splitterEngaged = v ?? false),
                ),

              const SizedBox(height: 12),
              _infoRow('Effective Final Drive', _effectiveFinalDrive()),
              _infoRow('Selected Gear Ratio', _selectedGearRatio()),

              const SizedBox(height: 16),
              _num(_mphCtrl, 'Speed (mph) → RPM'),
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
              _resultRow('RPM @ Speed', _rpmAtMph),

              const Divider(height: 32),

              _num(_rpmCtrl, 'Engine Speed (RPM) → MPH'),
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
              _resultRow('MPH @ RPM', _mphAtRpm),
            ]),
          ),
        ),
      ],
    );
  }

  // ---- UI helpers ----
  Widget _num(TextEditingController c, String label, {String? helper}) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, helperText: helper, border: const OutlineInputBorder()),
      );

  Widget _resultRow(String label, double? value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value == null ? '—' : value.toStringAsFixed(2)),
        ],
      );

  Widget _infoRow(String label, double value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toStringAsFixed(3)),
        ],
      );
}

// ------------------------------ CRANKSHAFT PAGE ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------ CRANKSHAFT PAGE (FIXED) ------------------------------
// ------------------------------ CRANKSHAFT PAGE (FINAL, RANGE-SAFE) ------------------------------
// ------------------------------ CRANKSHAFT PAGE (LIMITS + ROUNDNESS) ------------------------------
// ------------------------------ CRANKSHAFT PAGE (FINAL, RANGE-SAFE) ------------------------------
class CrankshaftPage extends StatefulWidget {
  const CrankshaftPage({super.key});
  @override
  State<CrankshaftPage> createState() => _CrankshaftPageState();
}

class _CrankshaftPageState extends State<CrankshaftPage> {
  // Counts
  int _numMains = 5;
  int _numRods  = 8;

  final TextEditingController _numMainsCtrl = TextEditingController(text: '5');
  final TextEditingController _numRodsCtrl  = TextEditingController(text: '8');

  // Cross-section toggle (two measurements per journal at ~90° apart)
  bool _crossSections = false;

  // Manufacturer limits toggle
  bool _limitsEnabled = false;
  final TextEditingController _mainMinCtrl = TextEditingController();
  final TextEditingController _mainMaxCtrl = TextEditingController();
  final TextEditingController _rodMinCtrl  = TextEditingController();
  final TextEditingController _rodMaxCtrl  = TextEditingController();

  // Measurement controllers
  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _rodA  = [];
  final List<TextEditingController> _rodB  = [];

  // Results (in same units as inputs)
  final List<double?> _mainRoundness = [];
  final List<double?> _rodRoundness  = [];

  // Limits results (null = not computed / not applicable)
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _rodWithinA  = [];
  final List<bool?> _rodWithinB  = [];

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
    for (final c in _mainA) { c.dispose(); }
    for (final c in _mainB) { c.dispose(); }
    for (final c in _rodA)  { c.dispose(); }
    for (final c in _rodB)  { c.dispose(); }
    super.dispose();
  }

  // --- ensure controller/result list sizes are always correct ---
  void _resizeLists() {
    _numMains = _numMains.clamp(1, 10);
    _numRods  = _numRods.clamp(1, 16);

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

    grow(_mainA, _numMains);  grow(_mainB, _numMains);
    grow(_rodA,  _numRods);   grow(_rodB,  _numRods);
    shrink(_mainA, _numMains); shrink(_mainB, _numMains);
    shrink(_rodA,  _numRods);  shrink(_rodB,  _numRods);

    while (_mainRoundness.length < _numMains) { _mainRoundness.add(null); }
    while (_mainRoundness.length > _numMains) { _mainRoundness.removeLast(); }
    while (_rodRoundness.length < _numRods)   { _rodRoundness.add(null); }
    while (_rodRoundness.length > _numRods)   { _rodRoundness.removeLast(); }

    while (_mainWithinA.length < _numMains) { _mainWithinA.add(null); }
    while (_mainWithinA.length > _numMains) { _mainWithinA.removeLast(); }
    while (_mainWithinB.length < _numMains) { _mainWithinB.add(null); }
    while (_mainWithinB.length > _numMains) { _mainWithinB.removeLast(); }

    while (_rodWithinA.length < _numRods) { _rodWithinA.add(null); }
    while (_rodWithinA.length > _numRods) { _rodWithinA.removeLast(); }
    while (_rodWithinB.length < _numRods) { _rodWithinB.add(null); }
    while (_rodWithinB.length > _numRods) { _rodWithinB.removeLast(); }
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
    for (int i = 0; i < _mainRoundness.length; i++) { _mainRoundness[i] = null; }
    for (int i = 0; i < _rodRoundness.length; i++)  { _rodRoundness[i]  = null; }
    for (int i = 0; i < _mainWithinA.length; i++)   { _mainWithinA[i]   = null; }
    for (int i = 0; i < _mainWithinB.length; i++)   { _mainWithinB[i]   = null; }
    for (int i = 0; i < _rodWithinA.length; i++)    { _rodWithinA[i]    = null; }
    for (int i = 0; i < _rodWithinB.length; i++)    { _rodWithinB[i]    = null; }
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
    final rodMin  = _limitsEnabled ? _p(_rodMinCtrl)  : null;
    final rodMax  = _limitsEnabled ? _p(_rodMaxCtrl)  : null;

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Crankshaft Measurements', style: TextStyle(fontWeight: FontWeight.w700)),
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
                IconButton(onPressed: () => _setMains(_numMains - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setMains(_numMains + 1), icon: const Icon(Icons.add_circle_outline)),
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
                IconButton(onPressed: () => _setRods(_numRods - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setRods(_numRods + 1), icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Enable A/B @ ~90° and compute |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() { _crossSections = v; _clearResults(); }),
              ),

              SwitchListTile(
                title: const Text('Check against manufacturer limits'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() { _limitsEnabled = v; _clearResults(); }),
              ),
              if (_limitsEnabled) ...[
                Row(children: [
                  Expanded(child: _numField(_mainMinCtrl, 'Main Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_mainMaxCtrl, 'Main Max')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _numField(_rodMinCtrl, 'Rod Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_rodMaxCtrl, 'Rod Max')),
                ]),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: Text(_crossSections
                      ? (_limitsEnabled ? 'Calculate Roundness & Limits' : 'Calculate Roundness')
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Main Journals', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numMains, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? _twoFieldRow(
                            label: 'Main ${i + 1}',
                            aCtrl: _mainA[i],
                            bCtrl: _mainB[i],
                            roundness: _mainRoundness[i],
                            withinA: _mainWithinA[i],
                            withinB: _mainWithinB[i],
                          )
                        : _singleFieldRow(
                            label: 'Main ${i + 1}',
                            ctrl: _mainA[i],
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rod Journals', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numRods, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? _twoFieldRow(
                            label: 'Rod ${i + 1}',
                            aCtrl: _rodA[i],
                            bCtrl: _rodB[i],
                            roundness: _rodRoundness[i],
                            withinA: _rodWithinA[i],
                            withinB: _rodWithinB[i],
                          )
                        : _singleFieldRow(
                            label: 'Rod ${i + 1}',
                            ctrl: _rodA[i],
                            within: _rodWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        _notesCard("""
Guidance:
• Enter all diameters using the same unit (in or mm).
• Cross-section A/B are taken ~90° apart; roundness = |A − B|.
• Limits: if enabled, each reading (A/B or single) is checked against min/max.
• If min > max, the check is skipped (invalid limits).
"""),
      ],
    );
  }

  // ---------- UI helpers ----------
  Widget _numField(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
      );

  Widget _statusChip(bool? ok) {
    if (ok == null) return const SizedBox.shrink();
    final Color base = ok ? Colors.green : Colors.red;
    final Color bg   = base.withValues(alpha: 0.12); // HDR-safe replacement
    final Color brd  = base;
    final Color txt  = ok ? Colors.green.shade800 : Colors.red.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brd),
      ),
      child: Text(ok ? 'OK' : 'OUT', style: TextStyle(color: txt, fontWeight: FontWeight.w700)),
    );
  }

  Widget _singleFieldRow({required String label, required TextEditingController ctrl, required bool? within}) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Diameter'),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(within),
      ],
    );
  }

  Widget _twoFieldRow({
    required String label,
    required TextEditingController aCtrl,
    required TextEditingController bCtrl,
    required double? roundness,
    required bool? withinA,
    required bool? withinB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: aCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'A', helperText: 'Dia @ 0°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinA),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'B', helperText: 'Dia @ 90°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinB),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Roundness', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(roundness == null ? '—' : roundness.toStringAsFixed(5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notesCard(String t) =>
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(t)));
}

// ------------------------------ ENGINE PAGE (MAINS + CYLINDERS) --------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------ ENGINE PAGE (MAINS + CYLINDERS) ------------------------------
class EnginePage extends StatefulWidget {
  const EnginePage({super.key});
  @override
  State<EnginePage> createState() => _EnginePageState();
}

class _EnginePageState extends State<EnginePage> {
  // Counts
  int _numMainBores = 5;
  int _numCylinders  = 8;

  final _numMainBoresCtrl = TextEditingController(text: '5');
  final _numCylindersCtrl = TextEditingController(text: '8');

  // Cross-section & limits
  bool _crossSections  = false;
  bool _limitsEnabled  = false;

  // Limits: mains and cylinders separate
  final _mainMinCtrl = TextEditingController();
  final _mainMaxCtrl = TextEditingController();
  final _cylMinCtrl  = TextEditingController();
  final _cylMaxCtrl  = TextEditingController();

  // Measurements (A/B lists for cross-sections)
  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _cylA  = [];
  final List<TextEditingController> _cylB  = [];

  // Roundness results (when cross-sections enabled)
  final List<double?> _mainRoundness = [];
  final List<double?> _cylRoundness  = [];

  // Limit checks
  final List<bool?> _mainWithinA = [];
  final List<bool?> _mainWithinB = [];
  final List<bool?> _cylWithinA  = [];
  final List<bool?> _cylWithinB  = [];

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
    for (final c in _mainA) { c.dispose(); }
    for (final c in _mainB) { c.dispose(); }
    for (final c in _cylA)  { c.dispose(); }
    for (final c in _cylB)  { c.dispose(); }
    super.dispose();
  }

  // ---------- sizing helpers ----------
  void _resizeLists() {
    _numMainBores = _numMainBores.clamp(1, 10);
    _numCylinders = _numCylinders.clamp(1, 16);

    void grow(List<TextEditingController> list, int to) {
      while (list.length < to) { list.add(TextEditingController()); }
    }
    void shrink(List<TextEditingController> list, int to) {
      while (list.length > to) { list.removeLast().dispose(); }
    }

    grow(_mainA, _numMainBores);   grow(_mainB, _numMainBores);
    grow(_cylA,  _numCylinders);   grow(_cylB,  _numCylinders);
    shrink(_mainA, _numMainBores); shrink(_mainB, _numMainBores);
    shrink(_cylA,  _numCylinders); shrink(_cylB,  _numCylinders);

    while (_mainRoundness.length < _numMainBores) { _mainRoundness.add(null); }
    while (_mainRoundness.length > _numMainBores) { _mainRoundness.removeLast(); }
    while (_cylRoundness.length < _numCylinders)  { _cylRoundness.add(null); }
    while (_cylRoundness.length > _numCylinders)  { _cylRoundness.removeLast(); }

    while (_mainWithinA.length < _numMainBores) { _mainWithinA.add(null); }
    while (_mainWithinA.length > _numMainBores) { _mainWithinA.removeLast(); }
    while (_mainWithinB.length < _numMainBores) { _mainWithinB.add(null); }
    while (_mainWithinB.length > _numMainBores) { _mainWithinB.removeLast(); }

    while (_cylWithinA.length < _numCylinders) { _cylWithinA.add(null); }
    while (_cylWithinA.length > _numCylinders) { _cylWithinA.removeLast(); }
    while (_cylWithinB.length < _numCylinders) { _cylWithinB.add(null); }
    while (_cylWithinB.length > _numCylinders) { _cylWithinB.removeLast(); }
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
    for (int i = 0; i < _mainRoundness.length; i++) { _mainRoundness[i] = null; }
    for (int i = 0; i < _cylRoundness.length; i++)  { _cylRoundness[i]  = null; }
    for (int i = 0; i < _mainWithinA.length; i++)   { _mainWithinA[i]   = null; }
    for (int i = 0; i < _mainWithinB.length; i++)   { _mainWithinB[i]   = null; }
    for (int i = 0; i < _cylWithinA.length; i++)    { _cylWithinA[i]    = null; }
    for (int i = 0; i < _cylWithinB.length; i++)    { _cylWithinB[i]    = null; }
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
    final cylMin  = _limitsEnabled ? _p(_cylMinCtrl)  : null;
    final cylMax  = _limitsEnabled ? _p(_cylMaxCtrl)  : null;

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Engine Measurements', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Use consistent units (in or mm). Enter bore diameters measured with a bore gauge.',
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
                    onChanged: (v) => _setMains(int.tryParse(v) ?? _numMainBores),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _setMains(_numMainBores - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setMains(_numMainBores + 1), icon: const Icon(Icons.add_circle_outline)),
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
                    onChanged: (v) => _setCyls(int.tryParse(v) ?? _numCylinders),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _setCyls(_numCylinders - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setCyls(_numCylinders + 1), icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Record A/B ~90° apart and compute |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() { _crossSections = v; _clearResults(); }),
              ),
              SwitchListTile(
                title: const Text('Check against manufacturer limits'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() { _limitsEnabled = v; _clearResults(); }),
              ),
              if (_limitsEnabled) ...[
                Row(children: [
                  Expanded(child: _numField(_mainMinCtrl, 'Main Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_mainMaxCtrl, 'Main Max')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _numField(_cylMinCtrl, 'Cylinder Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_cylMaxCtrl, 'Cylinder Max')),
                ]),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: Text(_crossSections
                      ? (_limitsEnabled ? 'Calculate Roundness & Limits' : 'Calculate Roundness')
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Main Housing Bores', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numMainBores, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? _twoFieldRow(
                            label: 'Main ${i + 1}',
                            aCtrl: _mainA[i],
                            bCtrl: _mainB[i],
                            roundness: _mainRoundness[i],
                            withinA: _mainWithinA[i],
                            withinB: _mainWithinB[i],
                          )
                        : _singleFieldRow(
                            label: 'Main ${i + 1}',
                            ctrl: _mainA[i],
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cylinder Bores', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numCylinders, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _crossSections
                        ? _twoFieldRow(
                            label: 'Cylinder ${i + 1}',
                            aCtrl: _cylA[i],
                            bCtrl: _cylB[i],
                            roundness: _cylRoundness[i],
                            withinA: _cylWithinA[i],
                            withinB: _cylWithinB[i],
                          )
                        : _singleFieldRow(
                            label: 'Cylinder ${i + 1}',
                            ctrl: _cylA[i],
                            within: _cylWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        _notesCard("""
Notes:
• Use the same units (in or mm) everywhere.
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• Limits are checked per reading (A/B or single) against min/max for mains and cylinders separately.
• If min > max, that limit set is treated as invalid and skipped.
"""),
      ],
    );
  }

  // ---------- UI helpers ----------
  Widget _numField(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
      );

  Widget _statusChip(bool? ok) {
    if (ok == null) return const SizedBox.shrink();
    final Color base = ok ? Colors.green : Colors.red;
    final Color bg   = base.withValues(alpha: 0.12); // HDR-safe replacement
    final Color brd  = base;
    final Color txt  = ok ? Colors.green.shade800 : Colors.red.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brd),
      ),
      child: Text(ok ? 'OK' : 'OUT', style: TextStyle(color: txt, fontWeight: FontWeight.w700)),
    );
  }

  Widget _singleFieldRow({required String label, required TextEditingController ctrl, required bool? within}) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Diameter'),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(within),
      ],
    );
  }

  Widget _twoFieldRow({
    required String label,
    required TextEditingController aCtrl,
    required TextEditingController bCtrl,
    required double? roundness,
    required bool? withinA,
    required bool? withinB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: aCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'A', helperText: 'Dia @ 0°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinA),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'B', helperText: 'Dia @ 90°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinB),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Roundness', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(roundness == null ? '—' : roundness.toStringAsFixed(5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notesCard(String t) =>
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(t)));
}

// ------------------------------ CONNECTING ROD PAGE ------------------------------
// ------------------------------ CONNECTING ROD PAGE (SIMPLIFIED) ------------------------------
// ------------------------------ CONNECTING ROD PAGE (SIMPLIFIED, FIXED) ------------------------------
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
  final List<double?> _pinRound = []; // <-- fixed generic

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
    for (final c in _bigA) { c.dispose(); }
    for (final c in _bigB) { c.dispose(); }
    for (final c in _pinA) { c.dispose(); }
    for (final c in _pinB) { c.dispose(); }
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

    grow(_bigA, _numRods);  grow(_bigB, _numRods);
    grow(_pinA, _numRods);  grow(_pinB, _numRods);
    shrink(_bigA, _numRods); shrink(_bigB, _numRods);
    shrink(_pinA, _numRods); shrink(_pinB, _numRods);

    while (_bigRound.length < _numRods) { _bigRound.add(null); }
    while (_bigRound.length > _numRods) { _bigRound.removeLast(); }
    while (_pinRound.length < _numRods) { _pinRound.add(null); }
    while (_pinRound.length > _numRods) { _pinRound.removeLast(); }

    while (_bigWithinA.length < _numRods) { _bigWithinA.add(null); }
    while (_bigWithinA.length > _numRods) { _bigWithinA.removeLast(); }
    while (_bigWithinB.length < _numRods) { _bigWithinB.add(null); }
    while (_bigWithinB.length > _numRods) { _bigWithinB.removeLast(); }

    while (_pinWithinA.length < _numRods) { _pinWithinA.add(null); }
    while (_pinWithinA.length > _numRods) { _pinWithinA.removeLast(); }
    while (_pinWithinB.length < _numRods) { _pinWithinB.add(null); }
    while (_pinWithinB.length > _numRods) { _pinWithinB.removeLast(); }
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
    for (int i = 0; i < _numRods; i++) {
      _bigRound[i] = null;
      _pinRound[i] = null;
      _bigWithinA[i] = null;
      _bigWithinB[i] = null;
      _pinWithinA[i] = null;
      _pinWithinB[i] = null;
    }
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Connecting Rod Bore Measurements', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Use consistent units (in or mm). Bores measured with a bore gauge.',
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
                IconButton(onPressed: () => _setCount(_numRods - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setCount(_numRods + 1), icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Record A/B ~90° apart; roundness = |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() { _crossSections = v; _clearResults(); }),
              ),
              SwitchListTile(
                title: const Text('Check against manufacturer min/max'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() { _limitsEnabled = v; _clearResults(); }),
              ),
              if (_limitsEnabled) ...[
                Row(children: [
                  Expanded(child: _numField(_bigMinCtrl, 'Big-End Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_bigMaxCtrl, 'Big-End Max')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _numField(_pinMinCtrl, 'Pin-End Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_pinMaxCtrl, 'Pin-End Max')),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Big-End Bore (crank end)', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numRods, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _crossSections
                      ? _twoFieldRow(
                          label: 'Rod ${i + 1}',
                          aCtrl: _bigA[i],
                          bCtrl: _bigB[i],
                          roundness: _bigRound[i],
                          withinA: _bigWithinA[i],
                          withinB: _bigWithinB[i],
                        )
                      : _singleFieldRow(
                          label: 'Rod ${i + 1}',
                          ctrl: _bigA[i],
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pin-End Bore (wrist pin)', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numRods, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _crossSections
                      ? _twoFieldRow(
                          label: 'Rod ${i + 1}',
                          aCtrl: _pinA[i],
                          bCtrl: _pinB[i],
                          roundness: _pinRound[i],
                          withinA: _pinWithinA[i],
                          withinB: _pinWithinB[i],
                        )
                      : _singleFieldRow(
                          label: 'Rod ${i + 1}',
                          ctrl: _pinA[i],
                          within: _pinWithinA[i],
                        ),
                )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        _notesCard("""
Notes:
• Enter all diameters using the same unit (in or mm).
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• If min > max, that limit set is treated as invalid and skipped.
"""),
      ],
    );
  }

  // ---------- UI helpers ----------
  Widget _numField(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
      );

  Widget _statusChip(bool? ok) {
    if (ok == null) return const SizedBox.shrink();
    final Color base = ok ? Colors.green : Colors.red;
    final Color bg   = base.withValues(alpha: 0.12); // HDR-safe (replaces withOpacity)
    final Color brd  = base;
    final Color txt  = ok ? Colors.green.shade800 : Colors.red.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brd),
      ),
      child: Text(ok ? 'OK' : 'OUT', style: TextStyle(color: txt, fontWeight: FontWeight.w700)),
    );
  }

  Widget _singleFieldRow({
    required String label,
    required TextEditingController ctrl,
    required bool? within,
  }) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Diameter'),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(within),
      ],
    );
  }

  Widget _twoFieldRow({
    required String label,
    required TextEditingController aCtrl,
    required TextEditingController bCtrl,
    required double? roundness,
    required bool? withinA,
    required bool? withinB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: aCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'A', helperText: 'Dia @ 0°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinA),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'B', helperText: 'Dia @ 90°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinB),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Roundness', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(roundness == null ? '—' : roundness.toStringAsFixed(5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notesCard(String t) =>
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(t)));
}

// ------------------------------ PISTON PAGE ------------------------------
// ------------------------------ PISTON PAGE ------------------------------
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
    for (final c in _pistonA) { c.dispose(); }   // <- braces added
    for (final c in _pistonB) { c.dispose(); }   // <- braces added
    super.dispose();
  }

  void _resizeLists() {
    _numPistons = _numPistons.clamp(1, 16);

    void grow(List<TextEditingController> list, int to) {
      while (list.length < to) { list.add(TextEditingController()); }
    }
    void shrink(List<TextEditingController> list, int to) {
      while (list.length > to) { list.removeLast().dispose(); }
    }

    grow(_pistonA, _numPistons);
    grow(_pistonB, _numPistons);
    shrink(_pistonA, _numPistons);
    shrink(_pistonB, _numPistons);

    while (_roundness.length < _numPistons) { _roundness.add(null); }
    while (_roundness.length > _numPistons) { _roundness.removeLast(); }

    while (_withinA.length < _numPistons) { _withinA.add(null); }
    while (_withinA.length > _numPistons) { _withinA.removeLast(); }

    while (_withinB.length < _numPistons) { _withinB.add(null); }
    while (_withinB.length > _numPistons) { _withinB.removeLast(); }
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
    for (int i = 0; i < _numPistons; i++) {
      _roundness[i] = null;
      _withinA[i] = null;
      _withinB[i] = null;
    }
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
          if (_crossSections) { _withinB[i] = _within(b, min, max); }
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Piston Measurements', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Use consistent units (in or mm).', style: TextStyle(color: cs.onSurfaceVariant)),
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
                IconButton(onPressed: () => _setCount(_numPistons - 1), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => _setCount(_numPistons + 1), icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Record A/B ~90° apart; roundness = |A − B|'),
                value: _crossSections,
                onChanged: (v) => setState(() { _crossSections = v; _clearResults(); }),
              ),
              SwitchListTile(
                title: const Text('Check against manufacturer min/max'),
                value: _limitsEnabled,
                onChanged: (v) => setState(() { _limitsEnabled = v; _clearResults(); }),
              ),
              if (_limitsEnabled)
                Row(children: [
                  Expanded(child: _numField(_minCtrl, 'Piston Min')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(_maxCtrl, 'Piston Max')),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Piston Diameters', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(_numPistons, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _crossSections
                      ? _twoFieldRow(
                          label: 'Piston ${i + 1}',
                          aCtrl: _pistonA[i],
                          bCtrl: _pistonB[i],
                          roundness: _roundness[i],
                          withinA: _withinA[i],
                          withinB: _withinB[i],
                        )
                      : _singleFieldRow(
                          label: 'Piston ${i + 1}',
                          ctrl: _pistonA[i],
                          within: _withinA[i],
                        ),
                )),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        _notesCard("""
Notes:
• Enter piston diameters using the same unit (in or mm).
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• If min > max, the limit set is treated as invalid and skipped.
"""),
      ],
    );
  }

  // ---------- UI helpers ----------
  Widget _numField(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
      );

  Widget _statusChip(bool? ok) {
    if (ok == null) return const SizedBox.shrink();
    final Color base = ok ? Colors.green : Colors.red;
    final Color bg   = base.withValues(alpha: 0.12);
    final Color brd  = base;
    final Color txt  = ok ? Colors.green.shade800 : Colors.red.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: brd)),
      child: Text(ok ? 'OK' : 'OUT', style: TextStyle(color: txt, fontWeight: FontWeight.w700)),
    );
  }

  Widget _singleFieldRow({required String label, required TextEditingController ctrl, required bool? within}) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Diameter'),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(within),
      ],
    );
  }

  Widget _twoFieldRow({
    required String label,
    required TextEditingController aCtrl,
    required TextEditingController bCtrl,
    required double? roundness,
    required bool? withinA,
    required bool? withinB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: aCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'A', helperText: 'Dia @ 0°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinA),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'B', helperText: 'Dia @ 90°'),
              ),
            ),
            const SizedBox(width: 8),
            _statusChip(withinB),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Roundness', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(roundness == null ? '—' : roundness.toStringAsFixed(5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notesCard(String t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(t)));
}
