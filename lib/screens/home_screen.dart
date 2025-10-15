import 'package:flutter/material.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/screens/indications_screen.dart';
import 'package:pediaid/screens/calculator_screen.dart';
import 'package:pediaid/screens/emergency_screen.dart';
import 'package:pediaid/screens/info_screen.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/screens/formulas_screen.dart';
import 'package:pediaid/screens/norms_screen.dart';
import 'package:pediaid/screens/search_screen.dart';
import 'package:pediaid/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _settings = SettingsService();
  double _ageYears = 5.0;
  double _weightKg = 20.0;
  double _heightCm = 110.0;
  int _selectedIndex = 0;
  WeightUnit _weightUnit = WeightUnit.kg;
  LengthUnit _lengthUnit = LengthUnit.cm;
  String _profileBadge = 'Allgemein (Standard)';

  PatientData get _patientData => PatientData(
    ageYears: _ageYears,
    weightKg: _weightKg,
    heightCm: _heightCm,
  );

  List<Widget> get _screens => [
    _buildHomeContent(),
    IndicationsScreen(patientData: _patientData),
    CalculatorScreen(patientData: _patientData),
    const InfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final wu = await _settings.getWeightUnit();
    final lu = await _settings.getLengthUnit();
    final defAge = await _settings.getDefaultAgeYears();
    final defWeightKg = await _settings.getDefaultWeightKg();
    final level = await _settings.getProfileLevel();
    final state = await _settings.getProfileState();
    final area = await _settings.getProfileArea();
    setState(() {
      _weightUnit = wu;
      _lengthUnit = lu;
      _ageYears = defAge;
      _weightKg = defWeightKg;
      _profileBadge = _composeProfile(level, state, area);
    });
  }

  double _kgToLbs(double kg) => kg * 2.2046226218;
  double _lbsToKg(double lbs) => lbs / 2.2046226218;
  double _cmToIn(double cm) => cm / 2.54;
  double _inToCm(double inch) => inch * 2.54;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: PediColors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Start'),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Indikationen'),
            BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Rechner'),
            BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final bsa = _patientData.calculateBSA();
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileBanner(context),
            const SizedBox(height: 16),
            Text(
              'PediAid',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: PediColors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pädiatrische Notfall-Hilfe',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patientendaten', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildSimpleSlider('Alter (Jahre)', _ageYears, 0, 18, (val) => setState(() => _ageYears = val), PediColors.pink),
                    const SizedBox(height: 20),
                    _buildWeightSlider(),
                    const SizedBox(height: 20),
                    _buildHeightSlider(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PediColors.yellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Körperoberfläche (m²)', style: Theme.of(context).textTheme.titleMedium),
                          Text('${bsa.toStringAsFixed(2)} m²', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Schnellzugriff', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickAccessCard(context, 'Indikationen', Icons.medical_services, PediColors.blue, () => setState(() => _selectedIndex = 1)),
                _buildQuickAccessCard(context, 'Rechner', Icons.calculate, PediColors.green, () => setState(() => _selectedIndex = 2)),
                _buildQuickAccessCard(context, 'Notfallmodus', Icons.emergency, PediColors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen(patientData: _patientData)));
                }),
                _buildQuickAccessCard(context, 'Suche', Icons.search, PediColors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                }),
                _buildQuickAccessCard(context, 'Formeln', Icons.functions, PediColors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FormulasScreen()));
                }),
                _buildQuickAccessCard(context, 'Normwerte', Icons.rule, PediColors.yellow, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NormsScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSlider(String label, double value, double min, double max, Function(double) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildWeightSlider() {
    final color = PediColors.blue;
    final unitLabel = _weightUnit == WeightUnit.kg ? 'kg' : 'lbs';
    final display = _weightUnit == WeightUnit.kg ? _weightKg : _kgToLbs(_weightKg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gewicht ($unitLabel)', style: Theme.of(context).textTheme.titleMedium),
            Text(display.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _weightKg,
            min: 3,
            max: 80,
            onChanged: (val) => setState(() => _weightKg = val),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightSlider() {
    final color = PediColors.green;
    final unitLabel = _lengthUnit == LengthUnit.cm ? 'cm' : 'inch';
    final display = _lengthUnit == LengthUnit.cm ? _heightCm : _cmToIn(_heightCm);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Größe ($unitLabel)', style: Theme.of(context).textTheme.titleMedium),
            Text(display.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _heightCm,
            min: 50,
            max: 180,
            onChanged: (val) => setState(() => _heightCm = val),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  String _composeProfile(String level, String? state, String? area) {
    if (level == 'area' && (state != null || area != null)) {
      return 'Profil: ${state ?? '-'} – ${area ?? '-'}';
    }
    if (level == 'state' && state != null) {
      return 'Profil: $state';
    }
    return 'Profil: Allgemein (Standard)';
  }

  Widget _profileBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => _loadSettings()),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.account_tree, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Regionale Leitlinien-Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_profileBadge, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
