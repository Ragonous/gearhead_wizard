import 'package:flutter/material.dart';

/// A reusable card for displaying notes or guidance text.
class NotesCard extends StatelessWidget {
  final String text;
  const NotesCard(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text(text)));
  }
}

/// A reusable numeric text input field.
class NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;

  const NumField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: helperText,
      ),
    );
  }
}

/// A chip to display OK/OUT status based on a boolean.
class StatusChip extends StatelessWidget {
  final bool? isOk;
  const StatusChip(this.isOk, {super.key});

  @override
  Widget build(BuildContext context) {
    if (isOk == null) return const SizedBox.shrink();

    final Color base = isOk! ? Colors.green : Colors.red;
    final Color bg = base.withAlpha(30); // Use a consistent, safe alpha
    final Color brd = base;
    final Color txt = isOk! ? Colors.green.shade800 : Colors.red.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: brd)),
      child: Text(isOk! ? 'OK' : 'OUT',
          style: TextStyle(color: txt, fontWeight: FontWeight.w700)),
    );
  }
}

/// A row for a single measurement input field with a status chip.
class SingleFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool? within;

  const SingleFieldRow({
    super.key,
    required this.label,
    required this.controller,
    required this.within,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(
          child: NumField(
            controller: controller,
            label: 'Diameter',
          ),
        ),
        const SizedBox(width: 8),
        StatusChip(within),
      ],
    );
  }
}

/// A row for two cross-section measurement fields (A/B) with status and roundness.
class TwoFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController aCtrl;
  final TextEditingController bCtrl;
  final double? roundness;
  final bool? withinA;
  final bool? withinB;

  const TwoFieldRow({
    super.key,
    required this.label,
    required this.aCtrl,
    required this.bCtrl,
    this.roundness,
    this.withinA,
    this.withinB,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: NumField(
                controller: aCtrl,
                label: 'A',
                helperText: 'Dia @ 0°',
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(withinA),
            const SizedBox(width: 12),
            Expanded(
              child: NumField(
                controller: bCtrl,
                label: 'B',
                helperText: 'Dia @ 90°',
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(withinB),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Roundness',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(roundness == null
                      ? '—'
                      : roundness!.toStringAsFixed(5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The application icon, with a fallback.
class AppIcon extends StatelessWidget {
  final double size;
  const AppIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 6),
      child: SizedBox(
        height: size,
        width: size,
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(child: FlutterLogo(size: size * 0.6)),
            );
          },
        ),
      ),
    );
  }
}