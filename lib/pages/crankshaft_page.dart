import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/crankshaft_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/ui_helpers.dart';

class CrankshaftPage extends StatefulWidget {
  const CrankshaftPage({super.key});
  @override
  State<CrankshaftPage> createState() => _CrankshaftPageState();
}

class _CrankshaftPageState extends State<CrankshaftPage> {
  // --- LOCAL UI CONTROLLERS ---
  final _numMainsCtrl = TextEditingController();
  final _numRodsCtrl = TextEditingController();
  final _mainMinCtrl = TextEditingController();
  final _mainMaxCtrl = TextEditingController();
  final _rodMinCtrl = TextEditingController();
  final _rodMaxCtrl = TextEditingController();

  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _rodA = [];
  final List<TextEditingController> _rodB = [];
  // --- END OF CONTROLLERS ---

  @override
  void initState() {
    super.initState();
    final provider = context.read<CrankshaftProvider>();

    // Set initial text for simple controllers
    _numMainsCtrl.text = provider.numMains.toString();
    _numRodsCtrl.text = provider.numRods.toString();
    _mainMinCtrl.text = provider.mainMin;
    _mainMaxCtrl.text = provider.mainMax;
    _rodMinCtrl.text = provider.rodMin;
    _rodMaxCtrl.text = provider.rodMax;

    // Add listeners to update provider when text changes
    _mainMinCtrl.addListener(() {
      context.read<CrankshaftProvider>().updateMainMin(_mainMinCtrl.text);
    });
    _mainMaxCtrl.addListener(() {
      context.read<CrankshaftProvider>().updateMainMax(_mainMaxCtrl.text);
    });
    _rodMinCtrl.addListener(() {
      context.read<CrankshaftProvider>().updateRodMin(_rodMinCtrl.text);
    });
    _rodMaxCtrl.addListener(() {
      context.read<CrankshaftProvider>().updateRodMax(_rodMaxCtrl.text);
    });

    // Initial fill of controller lists
    _syncControllerLists(provider);
  }

  @override
  void dispose() {
    _numMainsCtrl.dispose();
    _numRodsCtrl.dispose();
    _mainMinCtrl.dispose();
    _mainMaxCtrl.dispose();
    _rodMinCtrl.dispose();
    _rodMaxCtrl.dispose();

    for (final c in _mainA) c.dispose();
    for (final c in _mainB) c.dispose();
    for (final c in _rodA) c.dispose();
    for (final c in _rodB) c.dispose();
    
    super.dispose();
  }
  
  // Helper to sync our 4 UI lists with the provider's data
  void _syncControllerLists(CrankshaftProvider provider) {
    // A helper function to sync one list
    void syncList(
      List<TextEditingController> controllers,
      int targetSize,
      String Function(int) textSelector,
      void Function(int, String) updater,
    ) {
      // --- GROW ---
      while (controllers.length < targetSize) {
        final index = controllers.length;
        final text = textSelector(index);
        final ctrl = TextEditingController(text: text);
        
        ctrl.addListener(() {
          updater(index, ctrl.text);
        });
        controllers.add(ctrl);
      }
      
      // --- SHRINK ---
      while (controllers.length > targetSize) {
        final ctrl = controllers.removeLast();
        WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
      }
    }

    final providerRead = context.read<CrankshaftProvider>();
    // Sync Main lists
    syncList(
      _mainA,
      provider.numMains,
      (i) => provider.mainMeasurements[i].a,
      (i, v) => providerRead.updateMainA(i, v),
    );
    syncList(
      _mainB,
      provider.numMains,
      (i) => provider.mainMeasurements[i].b,
      (i, v) => providerRead.updateMainB(i, v),
    );
    
    // Sync Rod lists
    syncList(
      _rodA,
      provider.numRods,
      (i) => provider.rodMeasurements[i].a,
      (i, v) => providerRead.updateRodA(i, v),
    );
    syncList(
      _rodB,
      provider.numRods,
      (i) => provider.rodMeasurements[i].b,
      (i, v) => providerRead.updateRodB(i, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CrankshaftProvider>();

    _syncControllerLists(provider);
    
    if (_numMainsCtrl.text != provider.numMains.toString()) {
      _numMainsCtrl.text = provider.numMains.toString();
    }
    if (_numRodsCtrl.text != provider.numRods.toString()) {
      _numRodsCtrl.text = provider.numRods.toString();
    }

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
                    onChanged: (v) => provider.setNumMains(
                      int.tryParse(v) ?? provider.numMains
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => provider.setNumMains(provider.numMains - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => provider.setNumMains(provider.numMains + 1),
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
                    onChanged: (v) => provider.setNumRods(
                      int.tryParse(v) ?? provider.numRods
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => provider.setNumRods(provider.numRods - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => provider.setNumRods(provider.numRods + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle: const Text('Enable A/B @ ~90° and compute |A − B|'),
                value: provider.crossSections,
                onChanged: (v) => provider.setCrossSections(v),
              ),
              SwitchListTile(
                title: const Text('Check against manufacturer limits'),
                value: provider.limitsEnabled,
                onChanged: (v) => provider.setLimitsEnabled(v),
              ),
              if (provider.limitsEnabled) ...[
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
                  onPressed: () => provider.calculate(),
                  icon: const Icon(Icons.calculate),
                  label: Text(provider.crossSections
                      ? (provider.limitsEnabled
                          ? 'Calculate Roundness & Limits'
                          : 'Calculate Roundness')
                      : (provider.limitsEnabled ? 'Calculate Limits' : 'Calculate')),
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
                  children: List.generate(provider.numMains, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: provider.crossSections
                        ? TwoFieldRow(
                            key: ValueKey('main-$i'),
                            label: 'Main ${i + 1}',
                            aCtrl: _mainA[i],
                            bCtrl: _mainB[i],
                            roundness: provider.mainRoundness[i],
                            withinA: provider.mainWithinA[i],
                            withinB: provider.mainWithinB[i],
                          )
                        : SingleFieldRow(
                            key: ValueKey('main-$i'),
                            label: 'Main ${i + 1}',
                            controller: _mainA[i],
                            within: provider.mainWithinA[i],
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
                  children: List.generate(provider.numRods, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: provider.crossSections
                        ? TwoFieldRow(
                            key: ValueKey('rod-$i'),
                            label: 'Rod ${i + 1}',
                            aCtrl: _rodA[i],
                            bCtrl: _rodB[i],
                            roundness: provider.rodRoundness[i],
                            withinA: provider.rodWithinA[i],
                            withinB: provider.rodWithinB[i],
                          )
                        : SingleFieldRow(
                            key: ValueKey('rod-$i'),
                            label: 'Rod ${i + 1}',
                            controller: _rodA[i],
                            within: provider.rodWithinA[i],
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