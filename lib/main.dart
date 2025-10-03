import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/turbo_calculator_page.dart';
import 'pages/gear_ratio_calculator_page.dart';
import 'pages/crankshaft_page.dart';
import 'pages/engine_page.dart';
import 'pages/connecting_rod_page.dart';
import 'pages/piston_page.dart';

void main() => runApp(const GearheadWizardApp());

class GearheadWizardApp extends StatelessWidget {
  const GearheadWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gearhead Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4035),
          primary: const Color(0xFF2E4035), // Dark Olive Green
          secondary: const Color(0xFFD97706), // Orange accent
          surface: const Color(0xFFF9FAFB), // Light gray background
          onSurface: const Color(0xFF1F2937), // Dark text
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  void _onNavigate(int index) {
    setState(() {
      _index = index;
    });
  }

  // The list of pages is now built using the onNavigate callback
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigate: _onNavigate), // Pass the callback here
      const TurboCalculatorPage(),
      const GearRatioCalculatorPage(),
      const CrankshaftPage(),
      const EnginePage(),
      const ConnectingRodPage(),
      const PistonPage(),
    ];
  }

  final _titles = const [
    'Home',
    'Turbo Calculator',
    'Gear Ratio Calculator',
    'Crankshaft',
    'Engine',
    'Connecting Rod',
    'Piston'
  ];

  // List of icon asset paths
  static const List<String> _iconAssets = [
    'assets/icons/home_icon.png',
    'assets/icons/turbo_icon.png',
    'assets/icons/gears_icon.png',
    'assets/icons/crankshaft_icon.png',
    'assets/icons/engine_icon.png',
    'assets/icons/rod_icon.png',
    'assets/icons/piston_icon.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gearhead Wizard',
                applicationVersion: '1.0.0',
                applicationIcon: const AppIcon(size: 48),
                children: const [
                  SizedBox(height: 8),
                  Text(
                      'A growing toolkit for engine building, boost, gearing, and more.'),
                ],
              );
            },
          )
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        // Use a map to generate the destinations
        destinations: _titles.asMap().entries.map((entry) {
          int idx = entry.key;
          String title = entry.value;

          // For the home tab, we keep the label. For others, just the icon.
          return NavigationDestination(
            // UPDATED: Increased icon size from 24 (default) to 30
            icon: ImageIcon(AssetImage(_iconAssets[idx]), size: 30),
            label: title == 'Home'
                ? 'Home'
                : title.split(' ').first, // Use first word for label
          );
        }).toList(),
      ),
    );
  }
}

// Re-usable AppIcon widget from ui_helpers.dart (can be kept here or moved)
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
              child:
                  const Center(child: Icon(Icons.error, color: Colors.red)),
            );
          },
        ),
      ),
    );
  }
}