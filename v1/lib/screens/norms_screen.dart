import 'package:flutter/material.dart';

class NormsScreen extends StatelessWidget {
  const NormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Normwert-Karten')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NormCard(
            title: 'Atemfrequenz (AF) / min',
            items: [
              'Neugeboren: 30–60',
              '1–12 Monate: 30–50',
              '1–5 Jahre: 20–40',
              '6–12 Jahre: 18–30',
              'Jugendliche: 12–20',
            ],
          ),
          _NormCard(
            title: 'Herzfrequenz (HF) / min',
            items: [
              'Neugeboren: 110–160',
              '1–12 Monate: 100–150',
              '1–5 Jahre: 95–140',
              '6–12 Jahre: 80–120',
              'Jugendliche: 60–100',
            ],
          ),
          _NormCard(
            title: 'Syst. Blutdruck (Faustformel)',
            items: [
              '1–10 Jahre: 70 + (Alter×2) mmHg (untere Grenze)',
              'Normal: 90 + (Alter×2) mmHg',
            ],
          ),
          _NormCard(
            title: 'SpO₂',
            items: [
              'Zielbereich: ≥ 94% (ohne zyanotischen Herzfehler)',
            ],
          ),
          _NormCard(
            title: 'Temperatur',
            items: [
              'Normal: 36.5–37.5 °C',
            ],
          ),
          _SourceFootnote(),
        ],
      ),
    );
  }
}

class _NormCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _NormCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Quelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceFootnote extends StatelessWidget {
  const _SourceFootnote();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Text(
          'Orientierungswerte – klinische Entscheidung erforderlich.\nQuelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
