import 'package:shared_preferences/shared_preferences.dart';

/// Übernimmt Spielstand, Statistik und Einstellungen aus der Zeit vor der
/// Umbenennung in „Cold Compute". Läuft einmal und räumt die alten
/// Schlüssel danach weg.
class PrefsMigration {
  /// Alter Schlüssel → neuer Schlüssel.
  static const Map<String, String> renamed = {
    'ai2040_savegame_v1': 'coldcompute_savegame_v1',
    'ai2040_history_v1': 'coldcompute_history_v1',
    'ai2040_app_lang': 'coldcompute_app_lang',
    'ai2040_sound_enabled': 'coldcompute_sound_enabled',
  };

  static Future<void> run() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in renamed.entries) {
      if (!prefs.containsKey(entry.key)) continue;
      if (!prefs.containsKey(entry.value)) {
        final value = prefs.get(entry.key);
        if (value is String) await prefs.setString(entry.value, value);
        if (value is bool) await prefs.setBool(entry.value, value);
      }
      await prefs.remove(entry.key);
    }
  }
}
