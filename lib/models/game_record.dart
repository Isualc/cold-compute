import 'game_state.dart';
import 'metrics.dart';

/// Bilanz einer beendeten Partie — Grundlage der Spielstatistik.
class GameRecord {
  final String endedAtIso;
  final String roleId;

  /// Gespielter Plan-Pfad, z. B. 'A', 'D', 'B→A' (Umsteuern) oder '—'
  /// (Partie endete vor dem Fork von 2029).
  final String planPath;

  final String endingId;
  final String turnLabel;
  final int year;
  final String langName;
  final int alignment;
  final int trust;
  final int verification;
  final int decisions;
  final int seed;

  const GameRecord({
    required this.endedAtIso,
    required this.roleId,
    required this.planPath,
    required this.endingId,
    required this.turnLabel,
    required this.year,
    required this.langName,
    required this.alignment,
    required this.trust,
    required this.verification,
    required this.decisions,
    required this.seed,
  });

  factory GameRecord.fromState(GameState s, {DateTime? endedAt}) => GameRecord(
        endedAtIso: (endedAt ?? DateTime.now()).toIso8601String(),
        roleId: s.roleId,
        planPath: planPathFromFlags(s.flags),
        endingId: s.endingId ?? 'unbekannt',
        turnLabel: s.turnLabel,
        year: s.year,
        langName: s.lang.name,
        alignment: s.metric(Metric.alignment).round(),
        trust: s.metric(Metric.trust).round(),
        verification: s.metric(Metric.verification).round(),
        decisions:
            s.log.where((e) => e.kind == LogKind.decision).length,
        seed: s.seed,
      );

  /// Leitet aus den Spiel-Flags den Plan-Pfad ab. Spätwechsel zu Plan A
  /// (z. B. Plan B → Deal) werden als 'B→A' dargestellt.
  static String planPathFromFlags(Set<String> flags) {
    const order = ['plan_b', 'plan_c', 'plan_d', 'plan_s'];
    final before = [
      for (final id in order)
        if (flags.contains(id)) id.split('_').last.toUpperCase(),
    ];
    final hasA = flags.contains('plan_a');
    if (hasA && before.isNotEmpty) return '${before.join('/')}→A';
    if (hasA) return 'A';
    if (before.isNotEmpty) return before.join('/');
    return '—';
  }

  DateTime get endedAt =>
      DateTime.tryParse(endedAtIso) ?? DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toJson() => {
        'endedAt': endedAtIso,
        'roleId': roleId,
        'planPath': planPath,
        'endingId': endingId,
        'turnLabel': turnLabel,
        'year': year,
        'lang': langName,
        'alignment': alignment,
        'trust': trust,
        'verification': verification,
        'decisions': decisions,
        'seed': seed,
      };

  static GameRecord fromJson(Map<String, dynamic> j) => GameRecord(
        endedAtIso: j['endedAt'] as String? ?? '',
        roleId: j['roleId'] as String? ?? 'us_special_advisor',
        planPath: j['planPath'] as String? ?? '—',
        endingId: j['endingId'] as String? ?? 'unbekannt',
        turnLabel: j['turnLabel'] as String? ?? '',
        year: j['year'] as int? ?? 0,
        langName: j['lang'] as String? ?? 'de',
        alignment: j['alignment'] as int? ?? 0,
        trust: j['trust'] as int? ?? 0,
        verification: j['verification'] as int? ?? 0,
        decisions: j['decisions'] as int? ?? 0,
        seed: j['seed'] as int? ?? 0,
      );
}
