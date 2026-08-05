import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/scenario.dart';
import '../engine/game_engine.dart';
import '../models/directive.dart';
import '../engine/save_service.dart';
import '../l10n/strings.dart';
import '../models/game_event.dart';
import '../models/game_record.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../services/history_service.dart';
import '../services/prefs_migration.dart';

/// Bindet Engine, Spielstand und UI zusammen.
class GameProvider extends ChangeNotifier {
  final SaveService _saves = SaveService();
  late final GameEngine _engine = Scenario.buildEngine();

  static const _langKey = 'coldcompute_app_lang';
  static const _soundKey = 'coldcompute_sound_enabled';

  GameState? _state;
  final List<GameEvent> _pendingDecisions = [];
  Outcome? _lastOutcome;
  bool _hasSave = false;
  bool _busy = false;
  bool _soundEnabled = true;
  AppLang _appLang = AppLang.de;
  List<GameRecord> _history = [];

  /// Beendete Partien, neueste zuerst.
  List<GameRecord> get history => List.unmodifiable(_history);

  GameState? get state => _state;
  bool get hasSave => _hasSave;
  bool get isBusy => _busy;
  bool get soundEnabled => _soundEnabled;
  GameEngine get engine => _engine;

  /// Sprache der App-Oberfläche (Start, Codex). Eine laufende Partie
  /// behält die Sprache, in der sie begonnen wurde.
  AppLang get appLang => _appLang;

  /// Sprache für Szenario-Inhalte: die der laufenden Partie, sonst die App-Sprache.
  AppLang get contentLang => _state?.lang ?? _appLang;

  Strings get strings => Strings(contentLang);

  Future<void> setAppLang(AppLang lang) async {
    _appLang = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang.name);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  /// Aktuell anstehende Entscheidungskarte, null wenn die Runde fertig ist.
  GameEvent? get currentDecision =>
      _pendingDecisions.isEmpty ? null : _pendingDecisions.first;

  /// Zuletzt ausgewürfelter Ausgang (für die Ergebnisanzeige).
  Outcome? get lastOutcome => _lastOutcome;

  Future<void> init() async {
    // Spielstände aus der Zeit vor der Umbenennung übernehmen.
    await PrefsMigration.run();
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_langKey);
    _appLang = AppLang.values.firstWhere(
      (l) => l.name == stored,
      orElse: () => AppLang.de,
    );
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _hasSave = (await _saves.load()) != null;
    _history = await HistoryService.load();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    await HistoryService.clear();
    notifyListeners();
  }

  Future<void> newGame({required String roleId, int? seed}) async {
    if (_busy) return;
    _busy = true;
    final state = GameState.newGame(
      seed: seed ?? Random().nextInt(1 << 31),
      roleId: roleId,
      lang: _appLang,
    );
    // Rollenprofil anwenden: jede Rolle startet mit eigener Weltlage.
    final role = Scenario.roles.firstWhere(
      (r) => r.id == roleId,
      orElse: () => Scenario.roles.first,
    );
    role.startModifiers.forEach(state.applyDelta);
    _state = state;
    _pendingDecisions.clear();
    _lastOutcome = null;
    try {
      _advance();
      await _persist();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> continueGame() async {
    if (_busy) return false;
    _busy = true;
    try {
      final loaded = await _saves.load();
      if (loaded == null) return false;
      _state = loaded;
      _pendingDecisions
        ..clear()
        ..addAll(
          loaded.pendingEventIds
              .map((id) => _eventById(id))
              .whereType<GameEvent>(),
        );
      _lastOutcome = null;
      // The outcome effect was already persisted. Resume after its reveal so a
      // deterministic roll can never be applied twice.
      if (loaded.resolvedPendingEventId != null &&
          _pendingDecisions.isNotEmpty) {
        final resolvedId = loaded.resolvedPendingEventId;
        if (_pendingDecisions.first.id == resolvedId) {
          _pendingDecisions.removeAt(0);
          loaded.pendingEventIds.remove(resolvedId);
        }
        loaded.resolvedPendingEventId = null;
        await _persist();
      }
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Nächste Runde starten (Button „Weiter" nach abgeschlossener Runde).
  Future<void> nextTurn() async {
    final s = _state;
    if (_busy || s == null || s.isOver || _pendingDecisions.isNotEmpty) return;
    _busy = true;
    try {
      _advance();
      await _persist();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _advance() {
    final s = _state;
    if (s == null) return;
    final report = _engine.beginTurn(s);
    _pendingDecisions
      ..clear()
      ..addAll(report.pendingDecisions);
    s.pendingEventIds
      ..clear()
      ..addAll(report.pendingDecisions.map((event) => event.id));
    s.resolvedPendingEventId = null;
    _lastOutcome = null;
    lastDirective = null;
    lastDirectiveOutcome = null;
  }

  /// Spieler wählt eine Option der aktuellen Entscheidungskarte.
  Future<void> choose(EventChoice choice) async {
    final s = _state;
    final event = currentDecision;
    if (_busy ||
        s == null ||
        event == null ||
        !event.choices.contains(choice) ||
        !(choice.enabledIf?.call(s) ?? true)) {
      return;
    }
    _busy = true;
    try {
      _lastOutcome = _engine.resolveChoice(s, event, choice);
      s.resolvedPendingEventId = event.id;
      await _persist();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Zuletzt ausgeführte Direktive (für die Ergebnisanzeige im Ops-Panel).
  DirectiveOutcome? lastDirectiveOutcome;
  Directive? lastDirective;

  /// Verdeckte Operation anordnen.
  Future<void> runDirective(Directive directive) async {
    final s = _state;
    if (_busy || s == null || !_engine.canRunDirective(s, directive)) return;
    _busy = true;
    try {
      final outcome = _engine.runDirective(s, directive);
      if (outcome != null) {
        lastDirective = directive;
        lastDirectiveOutcome = outcome;
      }
      await _persist();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void clearDirectiveOutcome() {
    lastDirective = null;
    lastDirectiveOutcome = null;
    notifyListeners();
  }

  /// Ergebnisanzeige bestätigen, zur nächsten Entscheidung übergehen.
  Future<void> acknowledgeOutcome() async {
    if (_busy) return;
    _busy = true;
    final s = _state;
    if (_pendingDecisions.isNotEmpty) {
      final resolved = _pendingDecisions.removeAt(0);
      s?.pendingEventIds.remove(resolved.id);
    }
    if (s != null) s.resolvedPendingEventId = null;
    _lastOutcome = null;
    try {
      await _persist();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> abandonGame() async {
    if (_busy) return;
    _busy = true;
    await _saves.clear();
    _state = null;
    _pendingDecisions.clear();
    _lastOutcome = null;
    _hasSave = false;
    _busy = false;
    notifyListeners();
  }

  GameEvent? _eventById(String id) {
    for (final event in _engine.events) {
      if (event.id == id) return event;
    }
    return null;
  }

  Future<void> _persist() async {
    final s = _state;
    if (s == null) return;
    // Beendete Partie genau einmal in die Statistik übernehmen.
    if (s.isOver && !s.historyRecorded) {
      s.historyRecorded = true;
      final record = GameRecord.fromState(s);
      _history.insert(0, record);
      await HistoryService.add(record);
    }
    await _saves.save(s);
    _hasSave = true;
  }
}
