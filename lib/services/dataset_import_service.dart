import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service zum Importieren von Offline‑Datenpaketen.
///
/// Die ZIP‑Datei sollte die JSON‑Dateien `indications.json`, `medications.json`,
/// `checklists.json` und `guidelines.json` im Wurzelverzeichnis enthalten.
/// Beim Import werden diese Dateien entpackt und in den SharedPreferences
/// gespeichert, sodass die App beim nächsten Start oder Laden auf die neuen
/// Datensätze zugreift. Falls einzelne Dateien fehlen oder Fehler auftreten,
/// bleibt der bisherige Datensatz unverändert.
class DatasetImportService {
  /// Öffnet einen Dateiauswahldialog, entpackt das gewählte ZIP‑Paket und
  /// schreibt die enthaltenen JSON‑Dateien in den lokalen Speicher.
  Future<bool> importDataset() async {
    // Nutze den FilePicker, um eine ZIP‑Datei auszuwählen.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.isEmpty) {
      // Import abgebrochen.
      return false;
    }
    final file = result.files.single;
    // Lade die Bytes der ausgewählten Datei. Auf mobilen Plattformen
    // kann `file.bytes` null sein, wenn nur ein Pfad bereitgestellt wird.
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    // Entpacke das ZIP‑Archiv.
    final archive = ZipDecoder().decodeBytes(bytes);
    // Halte gefundene JSON‑Strings in einer Map.
    final Map<String, String> jsonFiles = {};
    for (final entry in archive) {
      if (entry.isFile) {
        final name = entry.name.split('/').last;
        if (name.endsWith('.json')) {
          final data = entry.content as List<int>;
          jsonFiles[name] = utf8.decode(data);
        }
      }
    }
    // Speichere die Daten in SharedPreferences, falls vorhanden.
    final prefs = await SharedPreferences.getInstance();
    bool updated = false;
    // JSON‑Validierung und Speicherfunktion mit erweiterten Schema‑Checks.
    // Der [schema] Parameter beschreibt erwartete Felder und Datentypen.
    // Unterstützte Typen: 'string', 'list', 'map', 'num'.
    bool _validateListWithSchema(dynamic parsed, Map<String, String> schema) {
      if (parsed is! List) return false;
      for (final item in parsed) {
        if (item is! Map) return false;
        for (final entry in schema.entries) {
          final key = entry.key;
          final type = entry.value;
          if (!item.containsKey(key)) return false;
          final value = item[key];
          switch (type) {
            case 'string':
              if (value is! String) return false;
              break;
            case 'list':
              if (value is! List) return false;
              break;
            case 'map':
              if (value is! Map) return false;
              break;
            case 'num':
              if (value is! num) return false;
              break;
            default:
              // Unknown type specifier; skip type check
              break;
          }
        }
      }
      return true;
    }

    Future<bool> tryStore(String key, String? content, Map<String, String> schema) async {
      if (content == null) return false;
      try {
        final parsed = json.decode(content);
        // Schema‑Check
        if (!_validateListWithSchema(parsed, schema)) {
          return false;
        }
        await prefs.setString(key, content);
        return true;
      } catch (e) {
        return false;
      }
    }
    // Erwartete Dateien und ihre Storage‑Keys. Beschreibe für jede Datei die erwarteten
    // Felder und deren Datentyp. Dies ermöglicht eine erweiterte JSON‑Validierung
    // und hilft, fehlerhafte Datensätze zu erkennen.
    final okInd = await tryStore(
      'indications',
      jsonFiles['indications.json'],
      {
        'id': 'string',
        'name': 'string',
      },
    );
    final okMed = await tryStore(
      'medications',
      jsonFiles['medications.json'],
      {
        'id': 'string',
        'name': 'string',
      },
    );
    final okChk = await tryStore(
      'checklists',
      jsonFiles['checklists.json'],
      {
        'id': 'string',
        'title': 'string',
        'steps': 'list',
      },
    );
    final okGuid = await tryStore(
      'guidelines',
      jsonFiles['guidelines.json'],
      {
        'id': 'string',
        'title': 'string',
        'summary': 'string',
        'details': 'string',
      },
    );
    updated = okInd || okMed || okChk || okGuid;
    return updated;
  }
}