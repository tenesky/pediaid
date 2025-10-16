import 'package:flutter/material.dart';
import 'package:pediaid/theme.dart';

class LegalScreen extends StatelessWidget {
  final String section;

  const LegalScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTitle(), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text(_getContent(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8)),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (section) {
      case 'impressum': return 'Impressum';
      case 'datenschutz': return 'Datenschutz';
      case 'haftung': return 'Haftungsausschluss';
      case 'quellen': return 'Quellenverzeichnis';
      default: return 'Information';
    }
  }

  String _getContent() {
    switch (section) {
      case 'impressum':
        return '''Angaben gemäß § 5 TMG

PediAid – Entwicklungsteam
[Platzhalter Name]
[Platzhalter Adresse]
[Platzhalter Stadt]

Kontakt:
E-Mail: [email protected]

Verantwortlich für den Inhalt:
[Platzhalter Name]

Hinweis:
Diese App wurde als Hilfsmittel für medizinisches Fachpersonal entwickelt. Sie dient ausschließlich der Information und Unterstützung bei der Dosisberechnung im pädiatrischen Notfall.''';

      case 'datenschutz':
        return '''Datenschutzerklärung

1. Datenerhebung
PediAid erhebt KEINE personenbezogenen Daten. Die App funktioniert vollständig offline und speichert ausschließlich lokale Einstellungen auf Ihrem Gerät.

2. Lokale Speicherung
Folgende Informationen werden nur lokal auf Ihrem Gerät gespeichert:
- Bestätigung des Haftungsausschlusses
- Zuletzt eingegebene Patientendaten (Alter, Gewicht, Größe)
- Datum der letzten Datenaktualisierung

3. Keine Datenübertragung
Es findet KEINE Übertragung von Daten an Server oder Dritte statt. Die App benötigt keine Internetverbindung.

4. Keine Werbung
PediAid zeigt keine Werbung und verwendet keine Tracking-Tools.

5. Ihre Rechte
Da keine personenbezogenen Daten erhoben werden, entfallen die üblichen Datenschutzrechte. Sie können die App jederzeit deinstallieren, um alle lokal gespeicherten Daten zu löschen.

Stand: 10/2025''';

      case 'haftung':
        return '''Haftungsausschluss

WICHTIGER HINWEIS

PediAid ist eine Entscheidungshilfe für medizinisches Fachpersonal und ersetzt KEINE klinische Entscheidung, ärztliche Beurteilung oder medizinische Ausbildung.

1. Medizinprodukt
Diese App ist KEIN Medizinprodukt im Sinne der EU-Verordnung 2017/745 (MDR). Sie dient ausschließlich der Information und Unterstützung.

2. Keine Gewährleistung
Alle Angaben wurden nach bestem Wissen und Gewissen zusammengestellt. Eine Gewähr für die Richtigkeit, Vollständigkeit und Aktualität kann jedoch NICHT übernommen werden.

3. Eigenverantwortung
Die Anwendung der bereitgestellten Informationen erfolgt ausschließlich in eigener Verantwortung des Nutzers. Jede medizinische Entscheidung muss individuell unter Berücksichtigung der klinischen Situation getroffen werden.

4. Haftungsausschluss
Der Entwickler übernimmt keine Haftung für Schäden oder Folgeschäden, die aus der Nutzung dieser App entstehen.

5. Nur für Fachpersonal
PediAid richtet sich ausschließlich an medizinisches Fachpersonal (Ärzt:innen, Notfallsanitäter:innen, Pflegepersonal mit entsprechender Qualifikation).

BITTE BESTÄTIGEN SIE VOR NUTZUNG, DASS SIE DIESE HINWEISE VERSTANDEN HABEN.''';

      case 'quellen':
        return '''Quellenverzeichnis

Die in PediAid verwendeten Daten basieren auf folgenden Leitlinien und Empfehlungen:

1. European Resuscitation Council (ERC)
European Resuscitation Council Guidelines 2025
Pediatric Life Support

2. Deutsche Interdisziplinäre Vereinigung für Intensiv- und Notfallmedizin (DIVI)
DIVI-Leitlinien 2024
S2k-Leitlinie Kindernotfall

3. Deutsche Gesellschaft für Kinder- und Jugendmedizin (DGKJ)
DGKJ-Leitlinien 2023
Handlungsempfehlungen pädiatrische Notfälle

4. Weitere Quellen
- Taschendorff-Dosierungstabellen
- Kindernotfall-ABC (verschiedene Rettungsdienstorganisationen)
- Broselow-Tape basierte Empfehlungen

HINWEIS:
Die Quellenlage wird kontinuierlich aktualisiert. Das Datum der letzten Aktualisierung finden Sie im Info-Bereich der App.

Alle Dosierungsangaben wurden mehrfach geprüft, eine Garantie für Richtigkeit kann jedoch nicht übernommen werden.

Bei Abweichungen oder Unsicherheiten konsultieren Sie bitte immer die aktuellen Fachinformationen und Leitlinien.''';

      default:
        return 'Keine Informationen verfügbar.';
    }
  }
}
