import 'package:flutter/material.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/screens/disclaimer_screen.dart';
import 'package:pediaid/screens/home_screen.dart';
import 'package:pediaid/screens/emergency_screen.dart';
import 'package:pediaid/screens/calculator_screen.dart';
import 'package:pediaid/screens/indications_screen.dart';
import 'package:pediaid/screens/legal_screen.dart';
import 'package:pediaid/screens/info_screen.dart';
import 'package:pediaid/screens/settings_screen.dart';
import 'package:pediaid/screens/search_screen.dart';
import 'package:pediaid/screens/formulas_screen.dart';
import 'package:pediaid/screens/norms_screen.dart';
import 'package:pediaid/screens/profile_screen.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/models/patient_data.dart';

void main() {
  runApp(const PediAidApp());
}

class PediAidApp extends StatelessWidget {
  const PediAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PediAid',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      // Apply a11y overrides
      builder: (context, child) {
        return FutureBuilder<List<bool>>(
          future: Future.wait([
            SettingsService().getLargeTextEnabled(),
            SettingsService().getHighContrastEnabled(),
          ]),
          initialData: const [false, false],
          builder: (context, snapshot) {
            final largeText = snapshot.data?[0] ?? false;
            final highContrast = snapshot.data?[1] ?? false;
            final mq = MediaQuery.of(context);
            final scaled = mq.copyWith(
              textScaler: TextScaler.linear(largeText ? 1.2 : 1.0),
              boldText: highContrast ? true : mq.boldText,
            );
            return MediaQuery(data: scaled, child: child ?? const SizedBox());
          },
        );
      },
      home: const InitialScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/indications': (context) => const _IndicationsRouteProxy(),
        '/calculator': (context) => const _CalculatorRouteProxy(),
        '/formulas': (context) => const FormulasScreen(),
        '/norms': (context) => const NormsScreen(),
        '/notfall': (context) => const _EmergencyRouteProxy(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/info': (context) => const InfoScreen(),
        '/legal': (context) => const LegalScreen(section: 'impressum'),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final _settingsService = SettingsService();
  bool _isLoading = true;
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final accepted = await _settingsService.hasAcceptedDisclaimer();
    setState(() {
      _hasAccepted = accepted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasAccepted ? const HomeScreen() : const DisclaimerScreen();
  }
}

// Route proxies build with default patient data; actual pages typically receive data via navigation.
class _IndicationsRouteProxy extends StatelessWidget {
  const _IndicationsRouteProxy({super.key});
  @override
  Widget build(BuildContext context) {
    return IndicationsScreen(
      patientData: PatientData(ageYears: 5, weightKg: 20, heightCm: 110),
    );
  }
}

class _CalculatorRouteProxy extends StatelessWidget {
  const _CalculatorRouteProxy({super.key});
  @override
  Widget build(BuildContext context) {
    return CalculatorScreen(
      patientData: PatientData(ageYears: 5, weightKg: 20, heightCm: 110),
    );
  }
}

class _EmergencyRouteProxy extends StatelessWidget {
  const _EmergencyRouteProxy({super.key});
  @override
  Widget build(BuildContext context) {
    return EmergencyScreen(
      patientData: PatientData(ageYears: 5, weightKg: 20, heightCm: 110),
    );
  }
}
