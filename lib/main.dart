import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gearhead_wizard/providers/turbo_provider.dart';
import 'package:gearhead_wizard/providers/piston_provider.dart';
import 'package:gearhead_wizard/providers/connecting_rod_provider.dart';
import 'package:gearhead_wizard/providers/crankshaft_provider.dart'; // 1. Import new provider

// Import all your pages
import 'package:gearhead_wizard/pages/connecting_rod_page.dart';
import 'package:gearhead_wizard/pages/crankshaft_page.dart';
import 'package:gearhead_wizard/pages/engine_page.dart';
import 'package:gearhead_wizard/pages/gear_ratio_calculator_page.dart';
import 'package:gearhead_wizard/pages/home_page.dart';
import 'package:gearhead_wizard/pages/piston_page.dart';
import 'package:gearhead_wizard/pages/turbo_calculator_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create and load all "brains"
  final turboProvider = TurboProvider();
  await turboProvider.loadData();

  final pistonProvider = PistonProvider();
  await pistonProvider.loadData();

  final connectingRodProvider = ConnectingRodProvider();
  await connectingRodProvider.loadData();

  // 2. Create and load new provider
  final crankshaftProvider = CrankshaftProvider();
  await crankshaftProvider.loadData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => turboProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => pistonProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => connectingRodProvider,
        ),
        // 3. Add new provider to the list
        ChangeNotifierProvider(
          create: (context) => crankshaftProvider,
        ),
      ],
      child: const GearheadWizardApp(),
    ),
  );
}

// --- The rest of your file is unchanged ---

class GearheadWizardApp extends StatelessWidget {
  const GearheadWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gearhead Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A4F41), // Dark Olive Green
          primary: const Color(0xFF3A4F41),
          secondary: const Color(0xFFD98D30), // Orange accent
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

  final _icons = const [
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
        destinations: List.generate(_titles.length, (i) {
          return NavigationDestination(
            icon: ImageIcon(AssetImage(_icons[i]), size: 28),
            label: _titles[i] == 'Connecting Rod' ? 'Con. Rod' : _titles[i],
          );
        }),
      ),
    );
  }
}

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