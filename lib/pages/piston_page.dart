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
  // --- LOCAL UI CONTROLLERS ---
  final _numCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  final List<TextEditingController> _pistonA = [];
  final List<TextEditingController> _pistonB = [];
  // --- END OF CONTROLLERS ---

  @override
  void initState() {
    super.initState();
    
    // 1. Get the provider *without* listening
    final provider = context.read<PistonProvider>();

    // 2. Set the *initial* text for the simple controllers
    _numCtrl.text = provider.numPistons.toString();
    _minCtrl.text = provider.min;
    _maxCtrl.text = provider.max;
    
    // 3. Add listeners to update the provider when text changes
    _minCtrl.addListener(() {
      context.read<PistonProvider>().updateMin(_minCtrl.text);
    });
    _maxCtrl.addListener(() {
      context.read<PistonProvider>().updateMax(_maxCtrl.text);
    });
    
    // 4. Do the *initial* fill of the controller lists
    _syncControllerLists(provider);
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
  
  // This is our new, combined sync logic.
  // It is called from build() and initState().
  void _syncControllerLists(PistonProvider provider) {
    // --- GROW ---
    // Add new controllers if provider has more pistons than we have controllers
    while (_pistonA.length < provider.numPistons) {
      final index = _pistonA.length;
      final text = provider.measurements[index].a;
      final ctrl = TextEditingController(text: text);
      
      // Add listener to update provider when UI text changes
      ctrl.addListener(() {
        // Use read() here, it's safer in a listener
        context.read<PistonProvider>().updateMeasurementA(index, ctrl.text);
      });
      _pistonA.add(ctrl);
    }
    while (_pistonB.length < provider.numPistons) {
      final index = _pistonB.length;
      final text = provider.measurements[index].b;
      final ctrl = TextEditingController(text: text);
      ctrl.addListener(() {
        context.read<PistonProvider>().updateMeasurementB(index, ctrl.text);
      });
      _pistonB.add(ctrl);
    }

    // --- SHRINK ---
    // Schedule disposal for *after* the build frame
    while (_pistonA.length > provider.numPistons) {
      final ctrl = _pistonA.removeLast();
      // Dispose after build to avoid errors
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    }
    while (_pistonB.length > provider.numPistons) {
      final ctrl = _pistonB.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the "brain" and WATCH for changes
    final provider = context.watch<PistonProvider>();

    // Run our sync logic *every build*.
    // This is now safe because:
    // 1. "Grow" just adds to a list (safe).
    // 2. "Shrink" schedules disposal for later (safe).
    // This ensures our controller lists are *always* the right size
    // *before* List.generate runs.
    _syncControllerLists(provider);
    
    // This check is for the _numCtrl only.
    // If the provider's count changed (e.g. invalid text), update the UI.
    if (_numCtrl.text != provider.numPistons.toString()) {
      _numCtrl.text = provider.numPistons.toString();
    }

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
                    onChanged: (v) {
                       // We just *tell* the provider.
                       // The provider will notify, and this widget will
                       // rebuild with the corrected value if needed.
                       provider.setNumPistons(
                         int.tryParse(v) ?? provider.numPistons
                       );
                    }
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

              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle:
                    const Text('Record A/B ~90° apart; roundness = |A − B|'),
                value: provider.crossSections,
                onChanged: (v) => provider.setCrossSections(v),
              ),
              
              SwitchListTile(
                title: const Text('Check against manufacturer min/max'),
                value: provider.limitsEnabled,
                onChanged: (v) => provider.setLimitsEnabled(v),
              ),
              
              if (provider.limitsEnabled)
                Row(children: [
                  Expanded(child: NumField(controller: _minCtrl, label: 'Piston Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _maxCtrl, label: 'Piston Max')),
                ]),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => provider.calculate(),
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
                // This is now safe, as _syncControllerLists
                // has already run.
                children: List.generate(
                    provider.numPistons,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: provider.crossSections
                              ? TwoFieldRow(
                                  key: ValueKey('piston-$i'),
                                  label: 'Piston ${i + 1}',
                                  aCtrl: _pistonA[i],
                                  bCtrl: _pistonB[i],
                                  roundness: provider.roundness[i],
                                  withinA: provider.withinA[i],
                                  withinB: provider.withinB[i],
                                )
                              : SingleFieldRow(
                                  key: ValueKey('piston-$i'),
                                  label: 'Piston ${i + 1}',
                                  controller: _pistonA[i],
                                  within: provider.withinA[i],
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