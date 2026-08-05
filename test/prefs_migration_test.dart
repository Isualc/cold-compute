import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cold_compute/providers/game_provider.dart';
import 'package:cold_compute/services/prefs_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Alte AI-2040-Schlüssel wandern nach Cold Compute', () async {
    SharedPreferences.setMockInitialValues({
      'ai2040_app_lang': 'en',
      'ai2040_sound_enabled': false,
      'ai2040_history_v1': '[]',
    });

    await PrefsMigration.run();
    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getString('coldcompute_app_lang'), 'en');
    expect(prefs.getBool('coldcompute_sound_enabled'), isFalse);
    expect(prefs.getString('coldcompute_history_v1'), '[]');
    // Die alten Schlüssel sind danach weg.
    for (final oldKey in PrefsMigration.renamed.keys) {
      expect(prefs.containsKey(oldKey), isFalse, reason: '$oldKey entfernt');
    }
  });

  test('Vorhandene neue Werte werden nicht überschrieben', () async {
    SharedPreferences.setMockInitialValues({
      'ai2040_app_lang': 'en',
      'coldcompute_app_lang': 'de',
    });

    await PrefsMigration.run();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('coldcompute_app_lang'), 'de');
    expect(prefs.containsKey('ai2040_app_lang'), isFalse);
  });

  test('Provider übernimmt Sprache aus dem alten Schlüssel', () async {
    SharedPreferences.setMockInitialValues({'ai2040_app_lang': 'en'});
    final provider = GameProvider();
    await provider.init();
    expect(provider.appLang.name, 'en');
  });
}
