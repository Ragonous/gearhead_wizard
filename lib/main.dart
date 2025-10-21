import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import all providers
import 'package:gearhead_wizard/providers/turbo_provider.dart';
import 'package:gearhead_wizard/providers/piston_provider.dart';
import 'package:gearhead_wizard/providers/connecting_rod_provider.dart';
import 'package:gearhead_wizard/providers/crankshaft_provider.dart';
import 'package:gearhead_wizard/providers/engine_provider.dart';
import 'package:gearhead_wizard/providers/gear_ratio_provider.dart';
import 'package:gearhead_wizard/providers/camshaft_provider.dart';

// Import all pages
import 'package:gearhead_wizard/pages/connecting_rod_page.dart';
import 'package:gearhead_wizard/pages/crankshaft_page.dart';
import 'package:gearhead_wizard/pages/engine_page.dart';
import 'package:gearhead_wizard/pages/gear_ratio_calculator_page.dart';
import 'package:gearhead_wizard/pages/home_page.dart';
import 'package:gearhead_wizard/pages/piston_page.dart';
import 'package:gearhead_wizard/pages/turbo_calculator_page.dart';
import 'package:gearhead_wizard/pages/camshaft_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all providers
  final turboProvider = TurboProvider()..loadData();
  final pistonProvider = PistonProvider()..loadData();
  final connectingRodProvider = ConnectingRodProvider()..loadData();
  final crankshaftProvider = CrankshaftProvider()..loadData();
  final engineProvider = EngineProvider()..loadData();
  final gearRatioProvider = GearRatioProvider()..loadData();
  final camshaftProvider = CamshaftProvider()..loadData();

  // Await all futures (more efficient)
  await Future.wait([
      turboProvider.loadData(),
      pistonProvider.loadData(),
      connectingRodProvider.loadData(),
      crankshaftProvider.loadData(),
      engineProvider.loadData(),
      gearRatioProvider.loadData(),
      camshaftProvider.loadData(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: turboProvider),
        ChangeNotifierProvider.value(value: pistonProvider),
        ChangeNotifierProvider.value(value: connectingRodProvider),
        ChangeNotifierProvider.value(value: crankshaftProvider),
        ChangeNotifierProvider.value(value: engineProvider),
        ChangeNotifierProvider.value(value: gearRatioProvider),
        ChangeNotifierProvider.value(value: camshaftProvider),
      ],
      child: const GearheadWizardApp(),
    ),
  );
}

// --- GearheadWizardApp --- (Unchanged)
class GearheadWizardApp extends StatelessWidget {
  const GearheadWizardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gearhead Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A4F41),
          primary: const Color(0xFF3A4F41),
          secondary: const Color(0xFFD98D30),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const RootScaffold(),
    );
  }
}

// --- RootScaffold --- (Unchanged)
class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  void _navigateToTab(int index) {
    setState(() {
      _index = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigate: _navigateToTab),
      const TurboCalculatorPage(),
      const GearRatioCalculatorPage(),
      const CrankshaftPage(),
      const EnginePage(),
      const ConnectingRodPage(),
      const PistonPage(),
      const CamshaftPage(),
    ];
  }

  final _titles = const [
    'Home',
    'Turbo Calc',
    'Gear Calc',
    'Crankshaft',
    'Engine',
    'Con. Rod',
    'Piston',
    'Camshaft',
  ];

  final _icons = const [
    'assets/icons/home_icon.png',
    'assets/icons/turbo_icon.png',
    'assets/icons/gears_icon.png',
    'assets/icons/crankshaft_icon.png',
    'assets/icons/engine_icon.png',
    'assets/icons/rod_icon.png',
    'assets/icons/piston_icon.png',
    'assets/icons/camshaft_icon.png',
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
                applicationVersion: '1.0.0', // Consider updating version later
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
        destinations: List.generate(_titles.length, (i) {
          final label = _titles[i]; // Use shortened title directly now
          return NavigationDestination(
            icon: ImageIcon(AssetImage(_icons[i]), size: 28),
            label: label,
          );
        }),
      ),
    );
  }
}

// --- AppIcon --- (Unchanged)
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
              child: Center(child: Icon(Icons.handyman, size: size * 0.6)),
            );
          },
        ),
      ),
    );
  }
}