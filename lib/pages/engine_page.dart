import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/engine_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/ui_helpers.dart';

class EnginePage extends StatefulWidget {
  const EnginePage({super.key});
  @override
  State<EnginePage> createState() => _EnginePageState();
}

class _EnginePageState extends State<EnginePage> {
  // --- LOCAL UI CONTROLLERS ---
  final _numMainBoresCtrl = TextEditingController();
  final _numCylindersCtrl = TextEditingController();
  final _mainMinCtrl = TextEditingController();
  final _mainMaxCtrl = TextEditingController();
  final _cylMinCtrl = TextEditingController();
  final _cylMaxCtrl = TextEditingController();

  final List<TextEditingController> _mainA = [];
  final List<TextEditingController> _mainB = [];
  final List<TextEditingController> _cylA = [];
  final List<TextEditingController> _cylB = [];
  // --- END OF CONTROLLERS ---

  @override
  void initState() {
    super.initState();
    final provider = context.read<EngineProvider>();

    // Set initial text for simple controllers
    _numMainBoresCtrl.text = provider.numMainBores.toString();
    _numCylindersCtrl.text = provider.numCylinders.toString();
    _mainMinCtrl.text = provider.mainMin;
    _mainMaxCtrl.text = provider.mainMax;
    _cylMinCtrl.text = provider.cylMin;
    _cylMaxCtrl.text = provider.cylMax;

    // Add listeners to update provider when text changes
    _mainMinCtrl.addListener(() {
      context.read<EngineProvider>().updateMainMin(_mainMinCtrl.text);
    });
    _mainMaxCtrl.addListener(() {
      context.read<EngineProvider>().updateMainMax(_mainMaxCtrl.text);
    });
    _cylMinCtrl.addListener(() {
      context.read<EngineProvider>().updateCylMin(_cylMinCtrl.text);
    });
    _cylMaxCtrl.addListener(() {
      context.read<EngineProvider>().updateCylMax(_cylMaxCtrl.text);
    });

    // Initial fill of controller lists
    _syncControllerLists(provider);
  }

  @override
  void dispose() {
    _numMainBoresCtrl.dispose();
    _numCylindersCtrl.dispose();
    _mainMinCtrl.dispose();
    _mainMaxCtrl.dispose();
    _cylMinCtrl.dispose();
    _cylMaxCtrl.dispose();

    for (final c in _mainA) c.dispose();
    for (final c in _mainB) c.dispose();
    for (final c in _cylA) c.dispose();
    for (final c in _cylB) c.dispose();
    
    super.dispose();
  }
  
  // Helper to sync our 4 UI lists with the provider's data
  void _syncControllerLists(EngineProvider provider) {
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

    final providerRead = context.read<EngineProvider>();
    // Sync Main lists
    syncList(
      _mainA,
      provider.numMainBores,
      (i) => provider.mainMeasurements[i].a,
      (i, v) => providerRead.updateMainA(i, v),
    );
    syncList(
      _mainB,
      provider.numMainBores,
      (i) => provider.mainMeasurements[i].b,
      (i, v) => providerRead.updateMainB(i, v),
    );
    
    // Sync Cylinder lists
    syncList(
      _cylA,
      provider.numCylinders,
      (i) => provider.cylMeasurements[i].a,
      (i, v) => providerRead.updateCylA(i, v),
    );
    syncList(
      _cylB,
      provider.numCylinders,
      (i) => provider.cylMeasurements[i].b,
      (i, v) => providerRead.updateCylB(i, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineProvider>();

    _syncControllerLists(provider);
    
    if (_numMainBoresCtrl.text != provider.numMainBores.toString()) {
      _numMainBoresCtrl.text = provider.numMainBores.toString();
    }
    if (_numCylindersCtrl.text != provider.numCylinders.toString()) {
      _numCylindersCtrl.text = provider.numCylinders.toString();
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
                      labelText: 'Main Bores', // RENAMED
                      helperText: '1–10',
                    ),
                    onChanged: (v) => provider.setNumMainBores(
                      int.tryParse(v) ?? provider.numMainBores
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => provider.setNumMainBores(provider.numMainBores - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => provider.setNumMainBores(provider.numMainBores + 1),
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
                    onChanged: (v) => provider.setNumCylinders(
                      int.tryParse(v) ?? provider.numCylinders
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => provider.setNumCylinders(provider.numCylinders - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => provider.setNumCylinders(provider.numCylinders + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),

              const Divider(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text('Cross-section (roundness) check'),
                subtitle:
                    const Text('Record A/B ~90° apart and compute |A − B|'),
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

        // Main bores
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Main Bores', // RENAMED
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                  children: List.generate(provider.numMainBores, (i) {
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
                  children: List.generate(provider.numCylinders, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: provider.crossSections
                        ? TwoFieldRow(
                            key: ValueKey('cyl-$i'),
                            label: 'Cylinder ${i + 1}',
                            aCtrl: _cylA[i],
                            bCtrl: _cylB[i],
                            roundness: provider.cylRoundness[i],
                            withinA: provider.cylWithinA[i],
                            withinB: provider.cylWithinB[i],
                          )
                        : SingleFieldRow(
                            key: ValueKey('cyl-$i'),
                            label: 'Cylinder ${i + 1}',
                            controller: _cylA[i],
                            within: provider.cylWithinA[i],
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