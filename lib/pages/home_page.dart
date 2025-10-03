import 'package:flutter/material.dart';
// ADDED: This line tells the home page where to find the AppIcon widget.
import 'package:gearhead_wizard/main.dart';

// Data class for our tools, using an asset path for the icon
class ToolInfo {
  final String title;
  final String subtitle;
  final String iconAsset;
  final int index;

  const ToolInfo({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.index,
  });
}

class HomePage extends StatelessWidget {
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  // List of all available tools with their icon asset paths
  static final List<ToolInfo> _tools = [
    const ToolInfo(
        title: 'Turbo',
        subtitle: 'PR & est. HP',
        iconAsset: 'assets/icons/turbo_icon.png',
        index: 1),
    const ToolInfo(
        title: 'Gears',
        subtitle: 'RPM ⇆ MPH',
        iconAsset: 'assets/icons/gears_icon.png',
        index: 2),
    const ToolInfo(
        title: 'Crankshaft',
        subtitle: 'Journal specs',
        iconAsset: 'assets/icons/crankshaft_icon.png',
        index: 3),
    const ToolInfo(
        title: 'Engine',
        subtitle: 'Bore specs',
        iconAsset: 'assets/icons/engine_icon.png',
        index: 4),
    const ToolInfo(
        title: 'Con. Rod',
        subtitle: 'Bore specs',
        iconAsset: 'assets/icons/rod_icon.png',
        index: 5),
    const ToolInfo(
        title: 'Piston',
        subtitle: 'Diameter specs',
        iconAsset: 'assets/icons/piston_icon.png',
        index: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // This will now work correctly because of the new import.
          const AppIcon(size: 120),
          const SizedBox(height: 16),
          Text(
            'Gearhead Wizard',
            style: textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your pocket toolbox for engine building and tuning.',
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _tools.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final tool = _tools[index];
              return _ToolActionCard(
                iconAsset: tool.iconAsset,
                title: tool.title,
                subtitle: tool.subtitle,
                onTap: () => onNavigate(tool.index),
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What's inside",
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const _ListLine(
                      icon: Icons.check_circle_outline,
                      text: 'Turbo & Gear Ratio Calculators'),
                  const _ListLine(
                      icon: Icons.check_circle_outline,
                      text: 'Crankshaft Journal Measurement Log'),
                  const _ListLine(
                      icon: Icons.check_circle_outline,
                      text: 'Engine & Connecting Rod Bore Logs'),
                  const _ListLine(
                      icon: Icons.check_circle_outline,
                      text: 'Piston Diameter Measurement Log'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card widget for the tool grid on the home page
class _ToolActionCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolActionCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageIcon(AssetImage(iconAsset), size: 28, color: cs.primary),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

// List line widget for the "What's inside" card
class _ListLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ListLine({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}