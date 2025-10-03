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
        colorSchemeSeed: Colors.teal,
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

  final _pages = const [
    HomePage(),
    TurboCalculatorPage(),
    GearRatioCalculatorPage(),
    CrankshaftPage(),
    EnginePage(),
    ConnectingRodPage(),
    PistonPage(),
  ];

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
      body: _pages[_index],
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