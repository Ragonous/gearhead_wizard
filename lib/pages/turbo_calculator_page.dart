import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

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

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

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
                  NumField(controller: _naHpCtrl, label: 'NA Horsepower (hp)'),
                  const SizedBox(height: 12),
                  NumField(controller: _boostPsiCtrl, label: 'Boost (psi)'),
                  const SizedBox(height: 12),
                  NumField(
                      controller: _efficiencyCtrl,
                      label: 'Efficiency (0.70–1.00)',
                      helperText: 'Default 0.90 for a healthy street setup'),
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
                    _ResultRow('Pressure Ratio', _pressureRatio),
                    const SizedBox(height: 8),
                    _ResultRow('Estimated Boosted HP', _boostedHp),
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