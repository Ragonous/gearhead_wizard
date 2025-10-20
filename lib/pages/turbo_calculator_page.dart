import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../providers/turbo_provider.dart'; // 2. Import our new "brain"
import '../widgets/ui_helpers.dart'; // [cite: 370]

class TurboCalculatorPage extends StatefulWidget {
  const TurboCalculatorPage({super.key}); // [cite: 370]
  @override
  State<TurboCalculatorPage> createState() => _TurboCalculatorPageState();
}

class _TurboCalculatorPageState extends State<TurboCalculatorPage> {
  // 3. Controllers still live in the UI
  final _naHpCtrl = TextEditingController();
  final _boostPsiCtrl = TextEditingController();
  final _efficiencyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 4. On start, get the "brain" (using context.read)
    // and set our text fields to match its saved data.
    final turbo = context.read<TurboProvider>();
    _naHpCtrl.text = turbo.naHp;
    _boostPsiCtrl.text = turbo.boostPsi;
    _efficiencyCtrl.text = turbo.efficiency;
  }

  @override
  void dispose() {
    // We still need to dispose our controllers
    _naHpCtrl.dispose();
    _boostPsiCtrl.dispose();
    _efficiencyCtrl.dispose();
    super.dispose();
  } // [cite: 372-373]

  // 5. This is our new calculate method
  void _calculate() {
    // Get the "brain" (using context.read)
    final turbo = context.read<TurboProvider>();

    // 6. Give the brain the UI's current text
    turbo.updateNaHp(_naHpCtrl.text.trim());
    turbo.updateBoostPsi(_boostPsiCtrl.text.trim());
    turbo.updateEfficiency(_efficiencyCtrl.text.trim());

    // 7. Tell the brain to calculate and save
    final String? error = turbo.calculate();

    // 8. Show a snackbar if the brain returned an error
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 9. Get the "brain" and WATCH for changes
    // This tells the UI to rebuild when notifyListeners() is called
    final turbo = context.watch<TurboProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 10. The TextFields use our local controllers
                  NumField(controller: _naHpCtrl, label: 'NA Horsepower (hp)'), // [cite: 380]
                  const SizedBox(height: 12),
                  NumField(controller: _boostPsiCtrl, label: 'Boost (psi)'), // [cite: 380]
                  const SizedBox(height: 12),
                  NumField(
                    controller: _efficiencyCtrl,
                    label: 'Efficiency (0.70–1.00)',
                    helperText: 'Default 0.90 for a healthy street setup',
                  ), // [cite: 381]
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    // 11. The button calls our new _calculate method
                    child: FilledButton.icon(
                      onPressed: _calculate, // [cite: 382]
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 12. This section now reads data *directly*
          //     from the "brain" (e.g., turbo.pressureRatio).
          //     Because of context.watch(), this will update
          //     automatically when you press "Calculate"!
          if (turbo.pressureRatio != null || turbo.boostedHp != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ResultRow('Pressure Ratio', turbo.pressureRatio), // [cite: 386]
                    const SizedBox(height: 8),
                    _ResultRow('Estimated Boosted HP', turbo.boostedHp), // [cite: 386]
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          const NotesCard("""
• Quick estimate—real results depend on compressor match, AFR, timing, IAT/intercooler, and back-pressure.
• Rough turbo sizing: target airflow (lb/min) ≈ target HP / 10.
"""), // [cite: 387]
        ],
      ),
    );
  }
}

// This widget stays exactly the same [cite: 388-390]
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