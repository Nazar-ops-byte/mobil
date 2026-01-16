import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'screens/profile_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_pin_screen.dart';
import 'services/pin_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ✅ Box’ları en başta aç
  await Hive.openBox('dumps');
  await Hive.openBox('app_prefs');
  await Hive.openBox('settings'); // PIN burada tutuluyor

  runApp(const OverthinkDumpApp());
}

class OverthinkDumpApp extends StatelessWidget {
  const OverthinkDumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppStartGate(),
    );
  }
}

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  bool? hasPin;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final pinService = PinService();
    final exists = await pinService.hasPin();
    if (!mounted) return;
    setState(() => hasPin = exists);
  }

  @override
  Widget build(BuildContext context) {
    if (hasPin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasPin == false) {
      return CreatePinScreen(
        onPinCreated: () {
          setState(() => hasPin = true);
        },
      );
    }

    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // 🔥 UYGULAMA PROFİL İLE BAŞLAR

  final List<Widget> _screens = const [
    HomeScreen(), // index 0 → Dump
    ProfileScreen(), // index 1 → Profil
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Dump',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'İçgörüler',
          ),
        ],
      ),
    );
  }
}
