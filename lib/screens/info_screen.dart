import 'package:flutter/material.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/screens/legal_screen.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/screens/settings_screen.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final _settingsService = SettingsService();
  String _lastUpdate = '10/2025';

  @override
  void initState() {
    super.initState();
    _loadUpdateInfo();
  }

  Future<void> _loadUpdateInfo() async {
    final date = await _settingsService.getLastUpdateDate();
    setState(() => _lastUpdate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info & Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.medical_services, size: 64, color: PediColors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'PediAid',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pädiatrische Notfall-Hilfe für medizinisches Fachpersonal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('Datenstand'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Letztes Update',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PediColors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _lastUpdate,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: PediColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Leitlinien: ERC 2025, DIVI 2024, DGKJ 2023',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Update-Funktion in Entwicklung')),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Daten aktualisieren'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PediColors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Regionale Profile können getrennt aktualisiert werden',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updates erfolgen künftig als Paket-Import. Aktuell Demo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('Einstellungen'),
          _buildMenuTile(context, 'Benutzereinstellungen', Icons.settings, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          const SizedBox(height: 24),
          _buildSection('Über die App'),
          _buildInfoCard(
            context,
            'Ziel',
            'PediAid ist eine Entscheidungshilfe für pädiatrische Notfälle. Sie richtet sich ausschließlich an medizinisches Fachpersonal und ersetzt keine klinische Entscheidung.',
            Icons.info_outline,
            PediColors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'Offline-Funktion',
            'Alle Daten sind lokal gespeichert. Die App benötigt keine Internetverbindung und sammelt keine personenbezogenen Daten.',
            Icons.offline_bolt,
            PediColors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'Haftungsausschluss',
            'Kein Medizinprodukt im Sinne der EU-Verordnung 2017/745 (MDR). Alle Angaben ohne Gewähr.',
            Icons.gavel,
            PediColors.red,
          ),
          const SizedBox(height: 24),
          _buildSection('Rechtliches'),
          _buildMenuTile(context, 'Impressum', Icons.business, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(section: 'impressum')));
          }),
          _buildMenuTile(context, 'Datenschutz', Icons.privacy_tip, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(section: 'datenschutz')));
          }),
          _buildMenuTile(context, 'Haftungsausschluss', Icons.warning_amber, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(section: 'haftung')));
          }),
          _buildMenuTile(context, 'Quellenverzeichnis', Icons.source, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(section: 'quellen')));
          }),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: PediColors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
