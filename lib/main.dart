import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/turbo_calculator_page.dart';
import 'pages/gear_ratio_calculator_page.dart';
import 'pages/crankshaft_page.dart';
import 'pages/engine_page.dart';
import 'pages/connecting_rod_page.dart';
import 'pages/piston_page.dart';
import 'widgets/ui_helpers.dart';

void main() => runApp(const GearheadWizardApp());

class GearheadWizardApp extends StatelessWidget {
  const GearheadWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gearhead Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A4F41),
          brightness: Brightness.light,
          primary: const Color(0xFF3A4F41),
          secondary: const Color(0xFFF39C12),
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

  // This is the function that changes the tab
  void _navigateToTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _index = index;
      });
    }
  }

  // Use late initialization to pass the navigation callback to the HomePage
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Define the pages list here instead of directly in the build method
    _pages = [
      // FIX: Pass the _navigateToTab function to the HomePage constructor
      HomePage(onNavigate: _navigateToTab),
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
                applicationVersion: '0.1.0',
                applicationIcon: const AppIcon(size: 48),
                children: const [
                  SizedBox(height: 8),
                  Text(
                      'A growing toolkit for gearheads: boost, gearing, and more.'),
                ],
              );
            },
          )
        ],
      ),
      // Use IndexedStack to keep the state of each page alive when switching tabs
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.bolt_outlined), label: 'Turbo'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Gears'),
          NavigationDestination(
              icon: Icon(Icons.build_outlined), label: 'Crank'),
          NavigationDestination(
              icon: Icon(Icons.precision_manufacturing_outlined),
              label: 'Engine'),
          NavigationDestination(icon: Icon(Icons.link_outlined), label: 'Rod'),
          NavigationDestination(
              icon: Icon(Icons.album_outlined), label: 'Piston'),
        ],
      ),
    );
  }
}