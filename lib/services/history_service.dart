import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_record.dart';

/// Persistente Partie-Historie (neueste zuerst, gedeckelt auf [maxEntries]).
class HistoryService {
  static const _key = 'coldcompute_history_v1';
  static const maxEntries = 100;

  static Future<List<GameRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final entry in list)
          GameRecord.fromJson(entry as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(GameRecord record) async {
    final records = await load();
    records.insert(0, record);
    await _save(records.take(maxEntries).toList());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(List<GameRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final r in records) r.toJson()]),
    );
  }
}
