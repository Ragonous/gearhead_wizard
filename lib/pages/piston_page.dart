import 'package:flutter/material.dart';
import 'package:gearhead_wizard/providers/piston_provider.dart';
import 'package:provider/provider.dart';
import 'package:gearhead_wizard/widgets/ui_helpers.dart';

class PistonPage extends StatefulWidget {
  const PistonPage({super.key});
  @override
  State<PistonPage> createState() => _PistonPageState();
}

class _PistonPageState extends State<PistonPage> {
  final _numCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  final List<TextEditingController> _pistonA = [];
  final List<TextEditingController> _pistonB = [];

  @override
  void initState() {
    super.initState();
    
    final provider = context.read<PistonProvider>();

    _numCtrl.text = provider.numPistons.toString();
    _minCtrl.text = provider.min;
    _maxCtrl.text = provider.max;
    
    _minCtrl.addListener(() {
      context.read<PistonProvider>().updateMin(_minCtrl.text);
    });
    _maxCtrl.addListener(() {
      context.read<PistonProvider>().updateMax(_maxCtrl.text);
    });
    
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
  
  void _syncControllerLists(PistonProvider provider) {
    while (_pistonA.length < provider.numPistons) {
      final index = _pistonA.length;
      final text = provider.measurements[index].a;
      final ctrl = TextEditingController(text: text);
      
      ctrl.addListener(() {
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

    while (_pistonA.length > provider.numPistons) {
      final ctrl = _pistonA.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    }
    while (_pistonB.length > provider.numPistons) {
      final ctrl = _pistonB.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PistonProvider>();

    _syncControllerLists(provider);
    
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