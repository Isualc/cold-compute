import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

/// Speichert genau einen Spielstand (Autosave nach jeder Runde).
class SaveService {
  static const _key = 'coldcompute_savegame_v1';
  static const int _schemaVersion = 2;

  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'schemaVersion': _schemaVersion, 'state': state.toJson()}),
    );
  }

  Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // v1 stored GameState directly. v2 wraps it so future migrations have
      // an explicit boundary without invalidating existing saves.
      final stateJson = decoded['state'] is Map<String, dynamic>
          ? decoded['state'] as Map<String, dynamic>
          : decoded;
      return GameState.fromJson(stateJson);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
