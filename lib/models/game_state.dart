import 'lang.dart';
import 'metrics.dart';

/// Phasen des US-China-Abkommens nach Plan A.
enum TreatyPhase {
  /// Kein Abkommen, offenes Rennen.
  none,

  /// Verhandlungen laufen.
  negotiation,

  /// Abkommen unterzeichnet, Aufbau des Verifikationsregimes.
  signed,

  /// Frontier-Training gedrosselt (ab ca. 2029).
  throttle,

  /// Pause auf Expertenniveau (ab ca. 2035).
  pause,

  /// Kontrollierter, gemeinsamer Aufstieg zur Superintelligenz (ab ca. 2040).
  controlledAscent,

  /// Globales Moratorium (Plan S): aller Frontier-Fortschritt gestoppt.
  moratorium,

  /// Abkommen zerbrochen — zurück ins Rennen.
  collapsed,
}

extension TreatyPhaseInfo on TreatyPhase {
  LText get labelText => switch (this) {
    TreatyPhase.none => const LText('Kein Abkommen', 'No treaty'),
    TreatyPhase.negotiation => const LText('Verhandlungen', 'Negotiations'),
    TreatyPhase.signed => const LText(
      'Abkommen unterzeichnet',
      'Treaty signed',
    ),
    TreatyPhase.throttle => const LText(
      'Frontier-Training gedrosselt',
      'Frontier training throttled',
    ),
    TreatyPhase.pause => const LText(
      'Pause auf Expertenniveau',
      'Pause at expert level',
    ),
    TreatyPhase.controlledAscent => const LText(
      'Kontrollierter Aufstieg',
      'Controlled ascent',
    ),
    TreatyPhase.moratorium => const LText(
      'Globales Moratorium',
      'Global moratorium',
    ),
    TreatyPhase.collapsed => const LText(
      'Abkommen zerbrochen',
      'Treaty collapsed',
    ),
  };

  String label(AppLang lang) => labelText.t(lang);
}

/// Ein Eintrag im Spielprotokoll (das „Sitzungsprotokoll" des Pen-and-Paper).
class LogEntry {
  final int turn;
  final String label; // z. B. 'H1 2027'
  final String title;
  final String text;
  final int? dieRoll; // W20-Ergebnis, falls gewürfelt wurde
  final LogKind kind;

  const LogEntry({
    required this.turn,
    required this.label,
    required this.title,
    required this.text,
    this.dieRoll,
    this.kind = LogKind.narration,
  });

  Map<String, dynamic> toJson() => {
    'turn': turn,
    'label': label,
    'title': title,
    'text': text,
    'dieRoll': dieRoll,
    'kind': kind.name,
  };

  static LogEntry fromJson(Map<String, dynamic> j) => LogEntry(
    turn: j['turn'] as int,
    label: j['label'] as String,
    title: j['title'] as String,
    text: j['text'] as String,
    dieRoll: j['dieRoll'] as int?,
    kind: LogKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => LogKind.narration,
    ),
  );
}

enum LogKind { narration, decision, outcome, worldTick, ending }

/// Vollständiger Zustand einer laufenden Partie.
class GameState {
  /// Rundenindex, 0 = H2 2026. Eine Runde = ein Halbjahr.
  int turn;

  final Map<Metric, double> metrics;
  TreatyPhase treatyPhase;
  final Set<String> flags;
  final Set<String> firedEvents;
  final List<LogEntry> log;

  /// Pending decision cards are part of the save game. Event ids are stable
  /// scenario data and can be resolved back to [GameEvent] by the provider.
  final List<String> pendingEventIds;

  /// Set after an outcome has been applied but before its reveal was
  /// acknowledged. On resume the applied outcome is never rolled twice.
  String? resolvedPendingEventId;

  /// Id des erreichten Endes, null solange die Partie läuft.
  String? endingId;

  /// Runde, in der das US-China-Abkommen unterzeichnet wurde (Deal-Decline-
  /// Uhr aus dem Supplement „Deal Decline"). Null = kein Abkommen.
  int? dealSignedTurn;

  /// Wurde diese Partie bereits in der Statistik erfasst?
  bool historyRecorded;

  /// Verdecktes Compute-Budget in Tausend H100-Äquivalenten (K H100e) —
  /// die Währung der Operationen. Im Szenario ist Compute die knappe
  /// strategische Ressource, nicht Geld.
  double compute;

  /// In dieser Runde bereits verbrauchte Operationsslots.
  int opsUsedThisTurn;

  /// Ids aller je ausgeführten Direktiven (für einmalige Operationen).
  final Set<String> executedDirectives;

  /// Saat für reproduzierbare Würfe.
  final int seed;

  /// Id der gewählten Spielerrolle.
  final String roleId;

  /// Sprache dieser Partie — das Protokoll wird in ihr geschrieben.
  final AppLang lang;

  GameState({
    required this.turn,
    required this.metrics,
    required this.treatyPhase,
    required this.flags,
    required this.firedEvents,
    required this.log,
    required this.pendingEventIds,
    required this.seed,
    required this.roleId,
    this.lang = AppLang.de,
    this.endingId,
    this.dealSignedTurn,
    this.resolvedPendingEventId,
    this.historyRecorded = false,
    this.compute = 120,
    this.opsUsedThisTurn = 0,
    Set<String>? executedDirectives,
  }) : executedDirectives = executedDirectives ?? <String>{};

  /// Operationsslots pro Halbjahr.
  static const int opsSlotsPerTurn = 2;

  int get opsSlotsLeft => opsSlotsPerTurn - opsUsedThisTurn;

  static const int startYear = 2026;

  /// H2 2026, H1 2027, …
  String get turnLabel {
    final year = startYear + ((turn + 1) ~/ 2);
    final half = (turn % 2 == 0) ? 'H2' : 'H1';
    return '$half $year';
  }

  int get year => startYear + ((turn + 1) ~/ 2);

  bool get isOver => endingId != null;

  double metric(Metric m) => metrics[m] ?? 0;

  void applyDelta(Metric m, double delta) {
    metrics[m] = ((metrics[m] ?? 0) + delta).clamp(0, 100);
  }

  /// Startet bei -1: der erste [GameEngine.beginTurn]-Aufruf zieht auf
  /// Runde 0 = H2 2026.
  factory GameState.newGame({
    required int seed,
    required String roleId,
    AppLang lang = AppLang.de,
  }) {
    return GameState(
      lang: lang,
      turn: -1,
      metrics: {
        Metric.usCapability: 18,
        Metric.cnCapability: 14,
        Metric.alignment: 12,
        Metric.trust: 20,
        Metric.verification: 5,
        Metric.publicPressure: 25,
        Metric.politicalCapital: 60,
        Metric.covertRisk: 15,
        Metric.escalation: 12,
        Metric.intel: 35,
      },
      treatyPhase: TreatyPhase.none,
      flags: <String>{},
      firedEvents: <String>{},
      log: <LogEntry>[],
      pendingEventIds: <String>[],
      seed: seed,
      roleId: roleId,
    );
  }

  Map<String, dynamic> toJson() => {
    'turn': turn,
    'metrics': metrics.map((k, v) => MapEntry(k.name, v)),
    'treatyPhase': treatyPhase.name,
    'flags': flags.toList(),
    'firedEvents': firedEvents.toList(),
    'log': log.map((e) => e.toJson()).toList(),
    'pendingEventIds': pendingEventIds,
    'resolvedPendingEventId': resolvedPendingEventId,
    'endingId': endingId,
    'dealSignedTurn': dealSignedTurn,
    'historyRecorded': historyRecorded,
    'compute': compute,
    'opsUsedThisTurn': opsUsedThisTurn,
    'executedDirectives': executedDirectives.toList(),
    'seed': seed,
    'roleId': roleId,
    'lang': lang.name,
  };

  static GameState fromJson(Map<String, dynamic> j) => GameState(
    turn: j['turn'] as int,
    metrics: (j['metrics'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        Metric.values.firstWhere((m) => m.name == k),
        (v as num).toDouble(),
      ),
    ),
    treatyPhase: TreatyPhase.values.firstWhere(
      (p) => p.name == j['treatyPhase'],
      orElse: () => TreatyPhase.none,
    ),
    flags: (j['flags'] as List).cast<String>().toSet(),
    firedEvents: (j['firedEvents'] as List).cast<String>().toSet(),
    log: (j['log'] as List)
        .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    pendingEventIds:
        (j['pendingEventIds'] as List?)?.cast<String>().toList() ?? <String>[],
    resolvedPendingEventId: j['resolvedPendingEventId'] as String?,
    endingId: j['endingId'] as String?,
    dealSignedTurn: j['dealSignedTurn'] as int?,
    historyRecorded: j['historyRecorded'] as bool? ?? false,
    compute: (j['compute'] as num?)?.toDouble() ?? 120,
    opsUsedThisTurn: j['opsUsedThisTurn'] as int? ?? 0,
    executedDirectives:
        (j['executedDirectives'] as List?)?.cast<String>().toSet() ??
            <String>{},
    seed: j['seed'] as int? ?? 0,
    roleId: j['roleId'] as String? ?? 'us_special_advisor',
    lang: AppLang.values.firstWhere(
      (l) => l.name == j['lang'],
      orElse: () => AppLang.de,
    ),
  );
}
