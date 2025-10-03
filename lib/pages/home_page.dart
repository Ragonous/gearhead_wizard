import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

// Data class for our tools
class ToolInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final int index;

  const ToolInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.index,
  });
}

class HomePage extends StatelessWidget {
  // Callback to navigate to a different tab
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  // List of all available tools
  static final List<ToolInfo> _tools = [
    ToolInfo(
        title: 'Turbo',
        subtitle: 'PR & est. HP',
        icon: Icons.bolt_outlined,
        index: 1),
    ToolInfo(
        title: 'Gears',
        subtitle: 'RPM ⇆ MPH',
        icon: Icons.settings_outlined,
        index: 2),
    ToolInfo(
        title: 'Crankshaft',
        subtitle: 'Journal specs',
        icon: Icons.build_outlined,
        index: 3),
    ToolInfo(
        title: 'Engine',
        subtitle: 'Bore specs',
        icon: Icons.precision_manufacturing_outlined,
        index: 4),
    ToolInfo(
        title: 'Con. Rod',
        subtitle: 'Bore specs',
        icon: Icons.link_outlined,
        index: 5),
    ToolInfo(
        title: 'Piston',
        subtitle: 'Diameter specs',
        icon: Icons.album_outlined,
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

          // New Grid layout for all the tools
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // FIX: Adjusted aspect ratio to give cards more height
              childAspectRatio: 1.4,
            ),
            itemCount: _tools.length,
            shrinkWrap: true, // Important for GridView in a Column
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
            itemBuilder: (context, index) {
              final tool = _tools[index];
              return _ToolActionCard(
                icon: tool.icon,
                title: tool.title,
                subtitle: tool.subtitle,
                onTap: () => onNavigate(tool.index),
              );
            },
          ),

          const SizedBox(height: 24),

          // Updated "What’s inside" list
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

// A more compact card for the GridView
class _ToolActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolActionCard({
    required this.icon,
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
              Icon(icon, size: 28, color: cs.primary),
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