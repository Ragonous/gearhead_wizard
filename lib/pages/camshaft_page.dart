import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/camshaft_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/ui_helpers.dart';

class CamshaftPage extends StatefulWidget {
  const CamshaftPage({super.key});
  @override
  State<CamshaftPage> createState() => _CamshaftPageState();
}

class _CamshaftPageState extends State<CamshaftPage> {
  // --- LOCAL UI CONTROLLERS --- (Unchanged)
  final _numJournalsCtrl = TextEditingController();
  final _journalMinCtrl = TextEditingController();
  final _journalMaxCtrl = TextEditingController();
  final _camEndplayCtrl = TextEditingController();
  final _camEndplayMinCtrl = TextEditingController();
  final _camEndplayMaxCtrl = TextEditingController();
  final List<TextEditingController> _journalA = [];
  final List<TextEditingController> _journalB = [];

  // --- initState --- (Unchanged)
  @override
  void initState() {
    super.initState();
    final provider = context.read<CamshaftProvider>();
    _numJournalsCtrl.text = provider.numJournals.toString();
    _journalMinCtrl.text = provider.journalMin;
    _journalMaxCtrl.text = provider.journalMax;
    _camEndplayCtrl.text = provider.camEndplay;
    _camEndplayMinCtrl.text = provider.camEndplayMin;
    _camEndplayMaxCtrl.text = provider.camEndplayMax;
    _journalMinCtrl.addListener(() {
      context.read<CamshaftProvider>().updateJournalMin(_journalMinCtrl.text);
    });
    _journalMaxCtrl.addListener(() {
      context.read<CamshaftProvider>().updateJournalMax(_journalMaxCtrl.text);
    });
    _camEndplayCtrl.addListener(() {
      context.read<CamshaftProvider>().updateCamEndplay(_camEndplayCtrl.text);
    });
     _camEndplayMinCtrl.addListener(() {
      context.read<CamshaftProvider>().updateCamEndplayMin(_camEndplayMinCtrl.text);
    });
     _camEndplayMaxCtrl.addListener(() {
      context.read<CamshaftProvider>().updateCamEndplayMax(_camEndplayMaxCtrl.text);
    });
    _syncControllerLists(provider);
  }

  // --- dispose --- (Unchanged)
  @override
  void dispose() {
    _numJournalsCtrl.dispose();
    _journalMinCtrl.dispose();
    _journalMaxCtrl.dispose();
    _camEndplayCtrl.dispose();
    _camEndplayMinCtrl.dispose();
    _camEndplayMaxCtrl.dispose();
    for (final c in _journalA) c.dispose();
    for (final c in _journalB) c.dispose();
    super.dispose();
  }

  // --- _syncControllerLists --- (Unchanged)
  void _syncControllerLists(CamshaftProvider provider) {
    void syncList(
      List<TextEditingController> controllers,
      String Function(int) textSelector,
      void Function(int, String) updater,
    ) {
      while (controllers.length < provider.numJournals) {
        final index = controllers.length;
        final text = textSelector(index);
        final ctrl = TextEditingController(text: text);
        ctrl.addListener(() {
          updater(index, ctrl.text);
        });
        controllers.add(ctrl);
      }
      while (controllers.length > provider.numJournals) {
        final ctrl = controllers.removeLast();
        WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
      }
    }
    final providerRead = context.read<CamshaftProvider>();
    syncList(_journalA, (i) => provider.journalMeasurements[i].a, (i,v) => providerRead.updateJournalA(i, v));
    syncList(_journalB, (i) => provider.journalMeasurements[i].b, (i,v) => providerRead.updateJournalB(i, v));
  }

  // --- build --- (Layout Corrected)
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CamshaftProvider>();

    _syncControllerLists(provider);

    // Sync simple controllers (Unchanged)
    if (_numJournalsCtrl.text != provider.numJournals.toString()) {
      _numJournalsCtrl.text = provider.numJournals.toString();
    }
    if (_camEndplayCtrl.text != provider.camEndplay) {
      _camEndplayCtrl.text = provider.camEndplay;
    }
    if (_camEndplayMinCtrl.text != provider.camEndplayMin) {
       _camEndplayMinCtrl.text = provider.camEndplayMin;
    }
     if (_camEndplayMaxCtrl.text != provider.camEndplayMax) {
       _camEndplayMaxCtrl.text = provider.camEndplayMax;
    }
     if (_journalMinCtrl.text != provider.journalMin) {
       _journalMinCtrl.text = provider.journalMin;
    }
     if (_journalMaxCtrl.text != provider.journalMax) {
       _journalMaxCtrl.text = provider.journalMax;
    }

    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Card 1: Setup & Journal Specs --- (Unchanged)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Camshaft Setup & Journal Specs',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Units: use the same units throughout (in or mm).',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _numJournalsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Camshaft Journals',
                      helperText: 'e.g., 5',
                    ),
                    onChanged: (v) => provider.setNumJournals(
                      int.tryParse(v) ?? provider.numJournals
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => provider.setNumJournals(provider.numJournals - 1),
                    icon: const Icon(Icons.remove_circle_outline)),
                IconButton(
                    onPressed: () => provider.setNumJournals(provider.numJournals + 1),
                    icon: const Icon(Icons.add_circle_outline)),
              ]),
              const Divider(height: 24),
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
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: NumField(controller: _journalMinCtrl, label: 'Journal Min')),
                  const SizedBox(width: 8),
                  Expanded(child: NumField(controller: _journalMaxCtrl, label: 'Journal Max')),
                ]),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => provider.calculateJournalSpecs(),
                  icon: const Icon(Icons.calculate),
                  label: Text(provider.crossSections
                      ? 'Calc Journal Specs & Roundness'
                      : 'Check Journal Specs'),
                ),
              ),
            ]),
          ),
        ), // End Card 1

        const SizedBox(height: 12),

        // --- Card 2: Journal Measurements --- (Unchanged)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Camshaft Journals',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                  children: List.generate(provider.numJournals, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: provider.crossSections
                        ? TwoFieldRow(
                            key: ValueKey('cam-journal-$i'),
                            label: 'Journal ${i + 1}',
                            aCtrl: _journalA[i],
                            bCtrl: _journalB[i],
                            roundness: provider.journalRoundness[i],
                            withinA: provider.journalWithinA[i],
                            withinB: provider.journalWithinB[i],
                          )
                        : SingleFieldRow(
                            key: ValueKey('cam-journal-$i'),
                            label: 'Journal ${i + 1}',
                            controller: _journalA[i],
                            within: provider.journalWithinA[i],
                          ),
                  );
                }),
              ),
            ]),
          ),
        ), // End Card 2

        const SizedBox(height: 12),

        // --- Card 3: Camshaft Endplay --- (Corrected Layout - Button inside if)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Camshaft Endplay',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  // Measured Endplay Input Row
                  Row(
                    children: [
                       Expanded(
                        child: NumField(
                          controller: _camEndplayCtrl,
                          label: 'Measured Endplay',
                          helperText: 'Check service manual for location'
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status chip shows ONLY if limits enabled
                      if(provider.limitsEnabled) StatusChip(provider.camEndplayWithin),
                    ],
                  ),
                  // Spec fields and button show ONLY if limits enabled
                  // *** THIS BLOCK IS NOW CORRECTLY STRUCTURED ***
                  if (provider.limitsEnabled) ...[
                     const SizedBox(height: 10), // Spacing
                     // Min/Max Spec Row
                     Row(children: [
                      Expanded(child: NumField(controller: _camEndplayMinCtrl, label: 'Endplay Min Spec')),
                      const SizedBox(width: 8),
                      Expanded(child: NumField(controller: _camEndplayMaxCtrl, label: 'Endplay Max Spec')),
                    ]),
                    const SizedBox(height: 12), // Spacing
                    // The second button is NOW correctly placed *inside* this if block
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => provider.calculateEndplayStatus(), // Correct action
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Check Endplay Spec'),
                      ),
                    ),
                  ] // <<< --- END of the if block --- >>>
                ]
            ),
          ),
        ), // End Card 3

        const SizedBox(height: 24),
        const NotesCard("""
Guidance:
• Use consistent units (in or mm).
• Camshaft endplay: fore/aft movement. Check service manual for measurement location.
• Cross-section A/B: ~90° apart; roundness = |A − B|.
• Limits check each reading against specs. If min > max, check skipped.
"""),
      ],
    );
  }
}