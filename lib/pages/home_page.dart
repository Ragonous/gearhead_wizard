import 'package:flutter/material.dart';
import '../widgets/ui_helpers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AppIcon(size: 120),
            const SizedBox(height: 16),
            Text(
              'Gearhead Wizard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your pocket toolbox for boost, gearing, and more.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bolt_outlined,
                    title: 'Turbo',
                    subtitle: 'PR & est. HP',
                    onTap: () => _goToTab(context, 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.settings_outlined,
                    title: 'Gears',
                    subtitle: 'RPM ⇆ MPH',
                    onTap: () => _goToTab(context, 2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // “What’s inside” list
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ListLine(
                        icon: Icons.check_circle_outline,
                        text:
                            'Turbo calculator (pressure ratio, estimated HP)'),
                    _ListLine(
                        icon: Icons.check_circle_outline,
                        text:
                            'Gear ratio calculator (RPM @ speed & speed @ RPM)'),
                    _ListLine(
                        icon: Icons.upcoming_outlined,
                        text:
                            'Coming soon: Compression ratio, injector sizing, tire/speedo'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CTA row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _goToTab(context, 1),
                    icon: const Icon(Icons.bolt_outlined),
                    label: const Text('Open Turbo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _goToTab(context, 2),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Open Gears'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    // This is a placeholder. A better approach is using a state management solution
    // (like Provider or Riverpod) or a callback from the RootScaffold to change the tab.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Navigation to tab $index needs to be handled by the root widget.')),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
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
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}