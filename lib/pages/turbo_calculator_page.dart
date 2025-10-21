import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearhead_wizard/providers/turbo_provider.dart';
import 'package:gearhead_wizard/widgets/ui_helpers.dart';

class TurboCalculatorPage extends StatefulWidget {
  const TurboCalculatorPage({super.key});
  @override
  State<TurboCalculatorPage> createState() => _TurboCalculatorPageState();
}

class _TurboCalculatorPageState extends State<TurboCalculatorPage> {
  final _naHpCtrl = TextEditingController();
  final _boostPsiCtrl = TextEditingController();
  final _efficiencyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final turbo = context.read<TurboProvider>();
    _naHpCtrl.text = turbo.naHp;
    _boostPsiCtrl.text = turbo.boostPsi;
    _efficiencyCtrl.text = turbo.efficiency;
  }

  @override
  void dispose() {
    _naHpCtrl.dispose();
    _boostPsiCtrl.dispose();
    _efficiencyCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final turbo = context.read<TurboProvider>();
    turbo.updateNaHp(_naHpCtrl.text.trim());
    turbo.updateBoostPsi(_boostPsiCtrl.text.trim());
    turbo.updateEfficiency(_efficiencyCtrl.text.trim());

    final String? error = turbo.calculate();

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  NumField(controller: _naHpCtrl, label: 'NA Horsepower (hp)'),
                  const SizedBox(height: 12),
                  NumField(controller: _boostPsiCtrl, label: 'Boost (psi)'),
                  const SizedBox(height: 12),
                  NumField(
                    controller: _efficiencyCtrl,
                    label: 'Efficiency (0.70–1.00)',
                    helperText: 'Default 0.90 for a healthy street setup',
                  ),
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
          
          if (turbo.pressureRatio != null || turbo.boostedHp != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ResultRow('Pressure Ratio', turbo.pressureRatio),
                    const SizedBox(height: 8),
                    _ResultRow('Estimated Boosted HP', turbo.boostedHp),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          const NotesCard("""
• Quick estimate—real results depend on compressor match, AFR, timing, IAT/intercooler, and back-pressure.
• Rough turbo sizing: target airflow (lb/min) ≈ target HP / 10.
"""),
        ],
      ),
    );
  }
}

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