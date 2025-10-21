import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/connecting_rod_provider.dart';
import 'package:provider/provider.dart';
import 'package:gearhead_wizard/widgets/ui_helpers.dart';

class ConnectingRodPage extends StatefulWidget {
  const ConnectingRodPage({super.key});
  @override
  State<ConnectingRodPage> createState() => _ConnectingRodPageState();
}

class _ConnectingRodPageState extends State<ConnectingRodPage> {
  final _numRodsCtrl = TextEditingController();
  final _bigMinCtrl = TextEditingController();
  final _bigMaxCtrl = TextEditingController();
  final _pinMinCtrl = TextEditingController();
  final _pinMaxCtrl = TextEditingController();

  final List<TextEditingController> _bigA = [];
  final List<TextEditingController> _bigB = [];
  final List<TextEditingController> _pinA = [];
  final List<TextEditingController> _pinB = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<ConnectingRodProvider>();

    _numRodsCtrl.text = provider.numRods.toString();
    _bigMinCtrl.text = provider.bigMin;
    _bigMaxCtrl.text = provider.bigMax;
    _pinMinCtrl.text = provider.pinMin;
    _pinMaxCtrl.text = provider.pinMax;

    _bigMinCtrl.addListener(() {
      context.read<ConnectingRodProvider>().updateBigMin(_bigMinCtrl.text);
    });
    _bigMaxCtrl.addListener(() {
      context.read<ConnectingRodProvider>().updateBigMax(_bigMaxCtrl.text);
    });
    _pinMinCtrl.addListener(() {
      context.read<ConnectingRodProvider>().updatePinMin(_pinMinCtrl.text);
    });
    _pinMaxCtrl.addListener(() {
      context.read<ConnectingRodProvider>().updatePinMax(_pinMaxCtrl.text);
    });

    _syncControllerLists(provider);
  }

  @override
  void dispose() {
    _numRodsCtrl.dispose();
    _bigMinCtrl.dispose();
    _bigMaxCtrl.dispose();
    _pinMinCtrl.dispose();
    _pinMaxCtrl.dispose();

    for (final c in _bigA) c.dispose();
    for (final c in _bigB) c.dispose();
    for (final c in _pinA) c.dispose();
    for (final c in _pinB) c.dispose();
    
    super.dispose();
  }
  
  void _syncControllerLists(ConnectingRodProvider provider) {
    void syncList(
      List<TextEditingController> controllers,
      String Function(int) textSelector,
      void Function(int, String) updater,
    ) {
      while (controllers.length < provider.numRods) {
        final index = controllers.length;
        final text = textSelector(index);
        final ctrl = TextEditingController(text: text);
        
        ctrl.addListener(() {
          updater(index, ctrl.text);
        });
        controllers.add(ctrl);
      }
      
      while (controllers.length > provider.numRods) {
        final ctrl = controllers.removeLast();
        WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
      }
    }

    final providerRead = context.read<ConnectingRodProvider>();
    syncList(
      _bigA,
      (i) => provider.measurements[i].bigA,
      (i, v) => providerRead.updateBigA(i, v),
    );
    syncList(
      _bigB,
      (i) => provider.measurements[i].bigB,
      (i, v) => providerRead.updateBigB(i, v),
    );
    syncList(
      _pinA,
      (i) => provider.measurements[i].pinA,
      (i, v) => providerRead.updatePinA(i, v),
    );
    syncList(
      _pinB,
      (i) => provider.measurements[i].pinB,
      (i, v) => providerRead.updatePinB(i, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectingRodProvider>();

    _syncControllerLists(provider);
    
    if (_numRodsCtrl.text != provider.numRods.toString()) {
      _numRodsCtrl.text = provider.numRods.toString();
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
              if (provider.limitsEnabled) ...[
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
              const Text('Big-End Bore (crank end)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                  children: List.generate(
                    provider.numRods,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: provider.crossSections
                              ? TwoFieldRow(
                                  key: ValueKey('big-$i'),
                                  label: 'Rod ${i + 1}',
                                  aCtrl: _bigA[i],
                                  bCtrl: _bigB[i],
                                  roundness: provider.bigRound[i],
                                  withinA: provider.bigWithinA[i],
                                  withinB: provider.bigWithinB[i],
                                )
                              : SingleFieldRow(
                                  key: ValueKey('big-$i'),
                                  label: 'Rod ${i + 1}',
                                  controller: _bigA[i],
                                  within: provider.bigWithinA[i],
                                ),
                        )),
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
              const Text('Pin-End Bore (wrist pin)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                    provider.numRods,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: provider.crossSections
                              ? TwoFieldRow(
                                  key: ValueKey('pin-$i'),
                                  label: 'Rod ${i + 1}',
                                  aCtrl: _pinA[i],
                                  bCtrl: _pinB[i],
                                  roundness: provider.pinRound[i],
                                  withinA: provider.pinWithinA[i],
                                  withinB: provider.pinWithinB[i],
                                )
                              : SingleFieldRow(
                                  key: ValueKey('pin-$i'),
                                  label: 'Rod ${i + 1}',
                                  controller: _pinA[i],
                                  within: provider.pinWithinA[i],
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