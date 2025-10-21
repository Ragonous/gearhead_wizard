import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/piston_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/ui_helpers.dart';

class PistonPage extends StatefulWidget {
  const PistonPage({super.key});
  @override
  State<PistonPage> createState() => _PistonPageState();
}

class _PistonPageState extends State<PistonPage> {
  // --- LOCAL UI CONTROLLERS --- (Unchanged)
  final _numCtrl = TextEditingController();
  final _pistonMinCtrl = TextEditingController();
  final _pistonMaxCtrl = TextEditingController();
  final _pinBoreMinCtrl = TextEditingController();
  final _pinBoreMaxCtrl = TextEditingController();
  final _wristPinMinCtrl = TextEditingController();
  final _wristPinMaxCtrl = TextEditingController();
  final List<TextEditingController> _pistonA = [];
  final List<TextEditingController> _pistonB = [];
  final List<TextEditingController> _pinBoreA = [];
  final List<TextEditingController> _pinBoreB = [];
  final List<TextEditingController> _wristPinOd = [];

  // --- initState --- (Unchanged)
  @override
  void initState() {
    super.initState();
    final provider = context.read<PistonProvider>();
    _numCtrl.text = provider.numPistons.toString();
    _pistonMinCtrl.text = provider.pistonMin;
    _pistonMaxCtrl.text = provider.pistonMax;
    _pinBoreMinCtrl.text = provider.pinBoreMin;
    _pinBoreMaxCtrl.text = provider.pinBoreMax;
    _wristPinMinCtrl.text = provider.wristPinMin;
    _wristPinMaxCtrl.text = provider.wristPinMax;
    _pistonMinCtrl.addListener(() {
      context.read<PistonProvider>().updatePistonMin(_pistonMinCtrl.text);
    });
    _pistonMaxCtrl.addListener(() {
      context.read<PistonProvider>().updatePistonMax(_pistonMaxCtrl.text);
    });
    _pinBoreMinCtrl.addListener(() {
      context.read<PistonProvider>().updatePinBoreMin(_pinBoreMinCtrl.text);
    });
    _pinBoreMaxCtrl.addListener(() {
      context.read<PistonProvider>().updatePinBoreMax(_pinBoreMaxCtrl.text);
    });
    _wristPinMinCtrl.addListener(() {
      context.read<PistonProvider>().updateWristPinMin(_wristPinMinCtrl.text);
    });
    _wristPinMaxCtrl.addListener(() {
      context.read<PistonProvider>().updateWristPinMax(_wristPinMaxCtrl.text);
    });
    _syncControllerLists(provider);
  }

  // --- dispose --- (Unchanged)
   @override
  void dispose() {
    _numCtrl.dispose();
    _pistonMinCtrl.dispose();
    _pistonMaxCtrl.dispose();
    _pinBoreMinCtrl.dispose();
    _pinBoreMaxCtrl.dispose();
    _wristPinMinCtrl.dispose();
    _wristPinMaxCtrl.dispose();
    for (final c in _pistonA) c.dispose();
    for (final c in _pistonB) c.dispose();
    for (final c in _pinBoreA) c.dispose();
    for (final c in _pinBoreB) c.dispose();
    for (final c in _wristPinOd) c.dispose();
    super.dispose();
  }

  // --- _syncControllerLists --- (Unchanged)
  void _syncControllerLists(PistonProvider provider) {
    void syncList(
      List<TextEditingController> controllers,
      String Function(int) textSelector,
      void Function(int, String) updater,
    ) {
      while (controllers.length < provider.numPistons) {
        final index = controllers.length;
        final text = textSelector(index);
        final ctrl = TextEditingController(text: text);
        ctrl.addListener(() {
          updater(index, ctrl.text);
        });
        controllers.add(ctrl);
      }
      while (controllers.length > provider.numPistons) {
        final ctrl = controllers.removeLast();
        WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
      }
    }
    final providerRead = context.read<PistonProvider>();
    syncList(_pistonA, (i) => provider.measurements[i].a, (i,v) => providerRead.updatePistonA(i, v));
    syncList(_pistonB, (i) => provider.measurements[i].b, (i,v) => providerRead.updatePistonB(i, v));
    syncList(_pinBoreA, (i) => provider.measurements[i].pinBoreA, (i,v) => providerRead.updatePinBoreA(i, v));
    syncList(_pinBoreB, (i) => provider.measurements[i].pinBoreB, (i,v) => providerRead.updatePinBoreB(i, v));
    syncList(_wristPinOd, (i) => provider.measurements[i].wristPinOd, (i,v) => providerRead.updateWristPinOd(i, v));
  }

  // --- build --- (Layout Updated)
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PistonProvider>();

    _syncControllerLists(provider);

    // Sync simple controllers (Unchanged)
    if (_numCtrl.text != provider.numPistons.toString()) {
      _numCtrl.text = provider.numPistons.toString();
    }
    if (_pistonMinCtrl.text != provider.pistonMin) {
       _pistonMinCtrl.text = provider.pistonMin;
    }
     if (_pistonMaxCtrl.text != provider.pistonMax) {
       _pistonMaxCtrl.text = provider.pistonMax;
    }
    if (_pinBoreMinCtrl.text != provider.pinBoreMin) {
       _pinBoreMinCtrl.text = provider.pinBoreMin;
    }
    if (_pinBoreMaxCtrl.text != provider.pinBoreMax) {
       _pinBoreMaxCtrl.text = provider.pinBoreMax;
    }
     if (_wristPinMinCtrl.text != provider.wristPinMin) {
       _wristPinMinCtrl.text = provider.wristPinMin;
    }
    if (_wristPinMaxCtrl.text != provider.wristPinMax) {
       _wristPinMaxCtrl.text = provider.wristPinMax;
    }

    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Card 1: Setup & Piston Specs ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Piston Setup & Diameter Specs', // Title updated
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text('Use consistent units (in or mm).',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),

                // Piston Count
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
                      onChanged: (v) => provider.setNumPistons(
                        int.tryParse(v) ?? provider.numPistons,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                      onPressed: () => provider.setNumPistons(provider.numPistons - 1),
                      icon: const Icon(Icons.remove_circle_outline)),
                  IconButton(
                      onPressed: () => provider.setNumPistons(provider.numPistons + 1),
                      icon: const Icon(Icons.add_circle_outline)),
                ]),

                const Divider(height: 24),

                // Toggles
                SwitchListTile(
                  title: const Text('Cross-section (roundness) check'),
                  subtitle: const Text('Record A/B ~90° apart; roundness = |A − B|'),
                  value: provider.crossSections,
                  onChanged: (v) => provider.setCrossSections(v),
                ),
                SwitchListTile(
                  title: const Text('Check against manufacturer limits'),
                  value: provider.limitsEnabled,
                  onChanged: (v) => provider.setLimitsEnabled(v),
                ),

                // Piston Diameter Spec Fields (only if limits enabled)
                if (provider.limitsEnabled) ...[
                   const SizedBox(height: 8),
                   Text('Piston Diameter Specs', style: Theme.of(context).textTheme.titleSmall),
                   Row(children: [
                    Expanded(child: NumField(controller: _pistonMinCtrl, label: 'Piston Dia Min')),
                    const SizedBox(width: 8),
                    Expanded(child: NumField(controller: _pistonMaxCtrl, label: 'Piston Dia Max')),
                   ]),
                   // Pin specs moved to Card 3
                ],

                const SizedBox(height: 16),
                // Button for Piston Diameter Calculation
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => provider.calculatePistonSpecs(), // Action updated
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Piston Diameter Specs'), // Label updated
                  ),
                ),
              ],
            ),
          ),
        ), // End Card 1

        const SizedBox(height: 12),

        // --- Card 2: Piston Diameter Measurements --- (Unchanged)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Piston Diameters',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(
                      provider.numPistons,
                      (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: provider.crossSections
                                ? TwoFieldRow(
                                    key: ValueKey('piston-dia-$i'),
                                    label: 'Piston ${i + 1}',
                                    aCtrl: _pistonA[i],
                                    bCtrl: _pistonB[i],
                                    roundness: provider.pistonRoundness[i],
                                    withinA: provider.pistonWithinA[i],
                                    withinB: provider.pistonWithinB[i],
                                  )
                                : SingleFieldRow(
                                    key: ValueKey('piston-dia-$i'),
                                    label: 'Piston ${i + 1}',
                                    controller: _pistonA[i],
                                    within: provider.pistonWithinA[i],
                                  ),
                          )),
                ),
              ],
            ),
          ),
        ), // End Card 2

        const SizedBox(height: 12),

        // --- Card 3: Pin Specs & Measurements ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pin Bore, Wrist Pin & Clearance', // Title updated
                    style: TextStyle(fontWeight: FontWeight.w700)),

                // Pin Spec Fields (only if limits enabled)
                if (provider.limitsEnabled) ...[
                   const SizedBox(height: 12), // Spacing added
                   Text('Pin Bore Specs', style: Theme.of(context).textTheme.titleSmall),
                   Row(children: [
                    Expanded(child: NumField(controller: _pinBoreMinCtrl, label: 'Pin Bore Min')),
                    const SizedBox(width: 8),
                    Expanded(child: NumField(controller: _pinBoreMaxCtrl, label: 'Pin Bore Max')),
                   ]),
                   const SizedBox(height: 10),
                   Text('Wrist Pin OD Specs', style: Theme.of(context).textTheme.titleSmall),
                   Row(children: [
                    Expanded(child: NumField(controller: _wristPinMinCtrl, label: 'Wrist Pin Min')),
                    const SizedBox(width: 8),
                    Expanded(child: NumField(controller: _wristPinMaxCtrl, label: 'Wrist Pin Max')),
                   ]),
                ],

                const SizedBox(height: 12), // Spacing before button
                // Button for Pin Calculation
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => provider.calculatePinSpecs(), // Action updated
                    icon: const Icon(Icons.calculate), // Maybe change icon?
                    label: const Text('Calculate Pin Specs & Clearance'), // Label updated
                  ),
                ),
                const Divider(height: 24),

                // Pin Measurement Input Fields
                 Column(
                  children: List.generate(
                      provider.numPistons,
                      (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pin Bore Input
                                provider.crossSections
                                  ? TwoFieldRow(
                                      key: ValueKey('pin-bore-$i'),
                                      label: 'Piston ${i + 1} Pin Bore',
                                      aCtrl: _pinBoreA[i],
                                      bCtrl: _pinBoreB[i],
                                      roundness: provider.pinBoreRoundness[i],
                                      withinA: provider.pinBoreWithinA[i],
                                      withinB: provider.pinBoreWithinB[i],
                                    )
                                  : SingleFieldRow(
                                      key: ValueKey('pin-bore-$i'),
                                      label: 'Piston ${i + 1} Pin Bore',
                                      controller: _pinBoreA[i],
                                      within: provider.pinBoreWithinA[i],
                                    ),
                                const SizedBox(height: 10),
                                // Wrist Pin Input
                                SingleFieldRow(
                                  key: ValueKey('wrist-pin-$i'),
                                  label: 'Piston ${i + 1} Pin OD',
                                  controller: _wristPinOd[i],
                                  within: provider.wristPinWithin[i],
                                ),
                                const SizedBox(height: 10),
                                // Calculated Pin Clearance Display
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('Pin Clearance: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                    Text(provider.pinClearance[i]?.toStringAsFixed(5) ?? '—'),
                                  ],
                                ),
                                if (i < provider.numPistons - 1) const Divider(height: 24),
                              ],
                            ),
                          )
                   ),
                ),
              ],
            ),
          ),
        ), // End Card 3

        const SizedBox(height: 24),
        const NotesCard("""
Notes:
• Enter measurements using the same unit (in or mm).
• Cross-section A/B are ~90° apart; roundness = |A − B|.
• Pin Clearance = Pin Bore ID - Wrist Pin OD. (Uses Avg Bore if A/B enabled).
• If min > max, limit checks are skipped.
"""),
      ],
    );
  }
}