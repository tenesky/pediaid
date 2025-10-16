import 'package:flutter/material.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/screens/home_screen.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  final _settingsService = SettingsService();
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Icon(Icons.medical_services, size: 80, color: PediColors.blue),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'PediAid',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PediColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Pädiatrische Notfall-Hilfe',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PediColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PediColors.red.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: PediColors.red, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'WICHTIGER HINWEIS',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PediColors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '''Diese App ist eine Entscheidungshilfe für medizinisches Fachpersonal und ersetzt KEINE klinische Entscheidung oder ärztliche Beurteilung.

• Kein Medizinprodukt im Sinne der EU-Verordnung 2017/745 (MDR)

• Alle Angaben ohne Gewähr

• Nutzung nur für medizinisches Fachpersonal

• Quellen: ERC 2025, DIVI 2024, DGKJ 2023

• Eigenverantwortliche Anwendung erforderlich''',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: InkWell(
                  onTap: () => setState(() => _isChecked = !_isChecked),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (val) => setState(() => _isChecked = val ?? false),
                          activeColor: PediColors.blue,
                        ),
                        Expanded(
                          child: Text(
                            'Ich bestätige, dass ich medizinisches Fachpersonal bin und die App nur als Entscheidungshilfe verwende.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecked ? _acceptAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PediColors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    'Weiter zur App',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isChecked ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptAndContinue() async {
    await _settingsService.acceptDisclaimer();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}
