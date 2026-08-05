import 'dart:math';

import '../models/directive.dart';
import '../models/ending.dart';
import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Ergebnis eines Rundenbeginns: was der „Spielleiter" vorliest und
/// welche Entscheidungen anstehen.
class TurnReport {
  final List<GameEvent> pendingDecisions;
  const TurnReport({required this.pendingDecisions});
}

/// Regelwerk-Engine: führt Runden aus, würfelt Ausgänge aus und prüft Enden.
///
/// Die Engine ist bewusst inhaltsfrei — Ereignisse, Enden und die
/// systemische Endauswertung kommen aus der Datenschicht (lib/data/).
class GameEngine {
  final List<GameEvent> events;
  final Map<String, Ending> endings;

  /// Systemische Endbedingungen (Fähigkeitsgrenzen, Vertragszerfall, Zeit).
  final String? Function(GameState state) evaluateEnding;

  GameEngine({
    required this.events,
    required this.endings,
    required this.evaluateEnding,
  });

  Random _rngFor(GameState state, [int salt = 0]) =>
      Random(state.seed ^ (state.turn * 7919) ^ salt);

  /// Dart's default String.hashCode is not guaranteed to stay stable across
  /// runtimes or releases. FNV-1a keeps seeded playthroughs reproducible on
  /// Android, Windows and Web.
  int _stableSalt(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Maximal so viele Entscheidungskarten pro Runde.
  static const int maxDecisionsPerTurn = 2;

  /// Weltdynamik pro Halbjahr, abhängig von Vertragsphase und gewähltem Plan.
  void _worldTick(GameState s) {
    final phase = s.treatyPhase;

    // Fähigkeitswachstum: offenes Rennen ist schnell, Drosselung bremst,
    // Pause friert nahe der Pausenlinie ein.
    double usGrowth;
    double cnGrowth;
    switch (phase) {
      case TreatyPhase.none:
      case TreatyPhase.collapsed:
        usGrowth = 3.4;
        cnGrowth = 3.0;
        break;
      case TreatyPhase.negotiation:
        usGrowth = 3.0;
        cnGrowth = 2.8;
        break;
      case TreatyPhase.signed:
        usGrowth = 2.4;
        cnGrowth = 2.2;
        break;
      case TreatyPhase.throttle:
        usGrowth = 1.2;
        cnGrowth = 1.1;
        break;
      case TreatyPhase.pause:
        usGrowth = 0.2;
        cnGrowth = 0.2;
        break;
      case TreatyPhase.controlledAscent:
        usGrowth = 2.6;
        cnGrowth = 2.6;
        break;
      case TreatyPhase.moratorium:
        // Plan S: Grundmodelle eingefroren; nur Scaffolding-Fortschritt.
        usGrowth = 0.15;
        cnGrowth = 0.15;
        break;
    }

    // Plan D: volles Renntempo durch die Intelligenzexplosion.
    if (s.flags.contains('plan_d')) {
      usGrowth += 1.6;
      cnGrowth += 1.2;
    }
    // Plan B: Sabotage bremst China, treibt aber die Eskalation.
    if (s.flags.contains('plan_b') && phase != TreatyPhase.signed) {
      cnGrowth = (cnGrowth - 1.0).clamp(0, 10);
    }

    // Compute-Overhang nach Vertragsbruch (Supplement „Deal Decline"):
    // je später der Bruch, desto mehr aufgestauter Compute, desto schneller
    // der unkontrollierte Takeoff. Greift die Zerstörungsklausel (MACD),
    // wird der Takeoff auf ~1 Jahr gestreckt statt ~9 Tage.
    if (phase == TreatyPhase.collapsed && s.dealSignedTurn != null) {
      final overhang = ((s.turn - s.dealSignedTurn!) / 10.0).clamp(0.0, 2.5);
      final macd = s.flags.contains('macd_ausgeloest');
      usGrowth += macd ? overhang * 0.4 : overhang * 2.0;
      cnGrowth += macd ? overhang * 0.4 : overhang * 2.0;
    }

    // Pausenlinie: in der Pause wächst nichts über Expertenniveau hinaus.
    if (phase == TreatyPhase.pause) {
      if (s.metric(Metric.usCapability) >= CapabilityMilestones.expertLevel) {
        usGrowth = 0;
      }
      if (s.metric(Metric.cnCapability) >= CapabilityMilestones.expertLevel) {
        cnGrowth = 0;
      }
    }

    s.applyDelta(Metric.usCapability, usGrowth);
    s.applyDelta(Metric.cnCapability, cnGrowth);

    // Alignment-Forschung profitiert massiv von Drosselung und Pause
    // (der ganze Sinn von Plan A: Zeit kaufen). Im Moratorium (Plan S)
    // fehlt dagegen die Frontier-Skalierung als Forschungswerkzeug.
    final alignmentGain = switch (phase) {
      TreatyPhase.pause => 2.6,
      TreatyPhase.throttle => 1.8,
      TreatyPhase.controlledAscent => 1.4,
      TreatyPhase.signed => 1.2,
      TreatyPhase.moratorium => 0.8,
      _ => 0.7,
    };
    s.applyDelta(Metric.alignment, alignmentGain);

    // Verifikation verfällt langsam ohne Pflege; verdecktes Risiko steigt,
    // wenn Verifikation schwach ist, und sinkt, wenn sie stark ist.
    if (phase == TreatyPhase.signed ||
        phase == TreatyPhase.throttle ||
        phase == TreatyPhase.pause ||
        phase == TreatyPhase.moratorium ||
        phase == TreatyPhase.controlledAscent) {
      s.applyDelta(Metric.verification, -0.5);
      final v = s.metric(Metric.verification);
      s.applyDelta(Metric.covertRisk, v >= 55 ? -1.5 : 1.5);
    } else {
      s.applyDelta(Metric.covertRisk, 1.0);
    }

    // Vertrauen erodiert im offenen Rennen.
    if (phase == TreatyPhase.none || phase == TreatyPhase.collapsed) {
      s.applyDelta(Metric.trust, -0.8);
    }

    _militaryTick(s);
  }

  /// Militärische Lage pro Halbjahr: Eskalation kühlt ohne neue Vorfälle
  /// langsam ab, Aufklärung verfällt ohne Nachschub, und das verdeckte
  /// Compute-Budget wächst je nach Phase der Wirtschaft.
  void _militaryTick(GameState s) {
    final phase = s.treatyPhase;

    // Abkühlung: Ein Vertrag mit funktionierenden Kanälen deeskaliert
    // schneller als ein offenes Rennen.
    final cooling = switch (phase) {
      TreatyPhase.throttle || TreatyPhase.pause => 4.5,
      TreatyPhase.signed || TreatyPhase.controlledAscent => 3.5,
      TreatyPhase.moratorium => 4.0,
      TreatyPhase.negotiation => 2.5,
      TreatyPhase.none => 1.5,
      TreatyPhase.collapsed => 0.5,
    };
    s.applyDelta(Metric.escalation, -cooling);

    // Ein zerbrochener Deal und laufende Sabotage-Programme heizen an.
    if (phase == TreatyPhase.collapsed) s.applyDelta(Metric.escalation, 4);
    if (s.flags.contains('plan_b')) s.applyDelta(Metric.escalation, 3);
    if (s.flags.contains('inspektionskrise')) {
      s.applyDelta(Metric.escalation, 5);
    }

    // Aufklärung veraltet; Ziele ändern Verfahren und Verschlüsselung.
    s.applyDelta(Metric.intel, -2.5);

    // Gute Aufklärung deckt verdeckte Programme früher auf.
    final intel = s.metric(Metric.intel);
    if (intel >= 60) s.applyDelta(Metric.covertRisk, -2);

    // Compute-Zufluss ins verdeckte Budget (K H100e pro Halbjahr).
    final income = switch (phase) {
      TreatyPhase.none || TreatyPhase.collapsed => 34.0,
      TreatyPhase.negotiation => 30.0,
      TreatyPhase.signed => 26.0,
      TreatyPhase.throttle => 20.0,
      TreatyPhase.controlledAscent => 24.0,
      TreatyPhase.pause => 14.0,
      TreatyPhase.moratorium => 9.0,
    };
    // Politisches Kapital öffnet Haushaltsspielräume.
    final political = s.metric(Metric.politicalCapital) / 100;
    s.compute = (s.compute + income * (.7 + political * .6)).clamp(0, 600);

    // Neue Runde, neue Stabskapazität.
    s.opsUsedThisTurn = 0;
  }

  /// Kann diese Direktive gerade angeordnet werden?
  bool canRunDirective(GameState s, Directive d) =>
      !s.isOver &&
      d.isAvailable(s) &&
      s.compute >= d.computeCost &&
      s.opsSlotsLeft >= d.slots;

  /// Direktive ausführen: W20 gegen die Erfolgschance, bei Misserfolg
  /// zweiter Wurf auf Attribution. Beides wird protokolliert.
  DirectiveOutcome? runDirective(GameState s, Directive d) {
    if (!canRunDirective(s, d)) return null;

    s.compute -= d.computeCost;
    s.opsUsedThisTurn += d.slots;
    s.executedDirectives.add(d.id);

    final rng = _rngFor(s, _stableSalt('${d.id}#${s.opsUsedThisTurn}'));
    final roll = rng.nextInt(20) + 1; // W20
    final target = (d.successChance(s) / 5).round(); // 0–20
    final succeeded = roll <= target;

    var outcome = succeeded ? d.success : d.failure;
    var exposed = outcome.exposed;
    if (!succeeded && exposed) {
      // Attribution ist ein eigener Wurf: nicht jeder Fehlschlag fliegt auf.
      exposed = rng.nextInt(100) < d.exposureChance(s);
    }

    s.log.add(LogEntry(
      turn: s.turn,
      label: s.turnLabel,
      title: '${d.domain.code} · ${d.name.t(s.lang)}',
      text: d.description.t(s.lang),
      kind: LogKind.decision,
    ));

    _applyEffect(s, outcome.effect);
    if (outcome.computeDelta != 0) {
      s.compute = (s.compute + outcome.computeDelta).clamp(0, 600);
    }

    // Aufgeflogene Operationen kosten zusätzlich Vertrauen und heizen an.
    if (exposed && !succeeded) {
      s.applyDelta(Metric.trust, -4);
      s.applyDelta(Metric.escalation, 6);
      if (s.metric(Metric.escalation) >= 70) s.flags.add('inspektionskrise');
    }

    final resultLabel = succeeded
        ? const LText('Operation erfolgreich', 'Operation successful')
        : (exposed
            ? const LText('Fehlschlag · aufgedeckt', 'Failure · attributed')
            : const LText(
                'Fehlschlag · nicht zugeordnet',
                'Failure · unattributed',
              ));

    s.log.add(LogEntry(
      turn: s.turn,
      label: s.turnLabel,
      title: resultLabel.t(s.lang),
      text: outcome.text.t(s.lang),
      dieRoll: roll,
      kind: LogKind.outcome,
    ));

    _checkEnding(s);
    return outcome;
  }

  /// Deal-Decline-Hazard nach dem Supplement „Deal Decline":
  /// ~11,6 %/Jahr in den Jahren 0–2, ~6,9 %/Jahr in 2–5, ~4,0 %/Jahr ab 5.
  /// Erhöht in den Regimewechsel-Fenstern (US-Wahlen 2032/2036, chinesische
  /// Nachfolge ~2033). Gute Politik (Vertrauen, Verifikation, politisches
  /// Kapital) senkt die Rate, schlechte erhöht sie.
  void _dealDeclineTick(GameState s) {
    final signedTurn = s.dealSignedTurn;
    final active =
        s.treatyPhase == TreatyPhase.signed ||
        s.treatyPhase == TreatyPhase.throttle ||
        s.treatyPhase == TreatyPhase.pause;
    if (signedTurn == null || !active) return;

    final dealYears = (s.turn - signedTurn) / 2.0;
    double annual;
    if (dealYears < 2) {
      annual = 0.116;
    } else if (dealYears < 5) {
      annual = 0.069;
    } else {
      annual = 0.040;
    }

    // Regimewechsel-Fenster: H2 2032 (Runde 12), 2033 (13/14), H2 2036 (20).
    if (s.turn == 12 || s.turn == 20) annual += 0.02;
    if (s.turn == 13 || s.turn == 14) annual += 0.01;

    // Lage-Modifikatoren: stabile Verhältnisse halbieren das Risiko,
    // zerrüttete verdoppeln es (grob).
    final stability =
        (s.metric(Metric.trust) +
            s.metric(Metric.verification) +
            s.metric(Metric.politicalCapital)) /
        3.0;
    annual *= (1.6 - stability / 100.0).clamp(0.5, 1.6);

    final perHalfYear = annual / 2.0;
    final rng = _rngFor(s, 4211);
    if (rng.nextDouble() >= perHalfYear) return;

    // Getroffen: hälftig Dissolution / Impairment (laut Supplement).
    if (rng.nextBool()) {
      // Impairment: der Deal besteht formal weiter, verliert aber Biss.
      s.applyDelta(Metric.verification, -12);
      s.applyDelta(Metric.trust, -6);
      s.applyDelta(Metric.covertRisk, 8);
      s.log.add(
        LogEntry(
          turn: s.turn,
          label: s.turnLabel,
          title: const LText(
            'Das Abkommen erodiert',
            'The treaty erodes',
          ).t(s.lang),
          text: const LText(
            'Kein Bruch, aber Verschleiß: Inspektionsfristen verstreichen, '
                'Meldungen kommen unvollständig, Beschwerden versanden in '
                'Arbeitsgruppen. Der Vertrag steht noch im Bundesgesetzblatt — '
                'nur glaubt ihm niemand mehr ganz.',
            'No rupture, just wear: inspection deadlines slip, filings arrive '
                'incomplete, complaints drown in working groups. The treaty is '
                'still on the books — people just no longer quite believe it.',
          ).t(s.lang),
          kind: LogKind.narration,
        ),
      );
    } else {
      // Dissolution: formaler Zusammenbruch. Greift die Zerstörungsklausel?
      final macd = s.metric(Metric.verification) >= 55;
      if (macd) s.flags.add('macd_ausgeloest');
      s.treatyPhase = TreatyPhase.collapsed;
      s.applyDelta(Metric.trust, -15);
      s.log.add(
        LogEntry(
          turn: s.turn,
          label: s.turnLabel,
          title: const LText('Der Deal zerbricht', 'The deal breaks').t(s.lang),
          text:
              (macd
                      ? const LText(
                          'Ein Führungswechsel kippt das Abkommen — doch die '
                              'Zerstörungsklausel greift: Beide Seiten verlieren den '
                              'Großteil ihrer Nachvertrags-Hardware. Das Rennen '
                              'beginnt neu, aber gedrosselt: Der Takeoff wird sich '
                              'über Jahre ziehen, nicht über Tage.',
                          'A change in leadership topples the treaty — but the '
                              'destruction clause bites: both sides lose most of '
                              'their post-deal hardware. The race resumes, yet '
                              'throttled — the takeoff will stretch over years, '
                              'not days.',
                        )
                      : const LText(
                          'Das Abkommen kollabiert — und die Zerstörungsklausel '
                              'bleibt stumpf, weil das Verifikationsregime zu '
                              'schwach war, um sie durchzusetzen. Der aufgestaute '
                              'Compute-Überhang entlädt sich: Das Rennen kehrt '
                              'zurück, um ein Vielfaches schneller als 2029.',
                          'The treaty collapses — and the destruction clause stays '
                              'blunt, because the verification regime was too weak '
                              'to enforce it. The pent-up compute overhang '
                              'discharges: the race returns, many times faster '
                              'than in 2029.',
                        ))
                  .t(s.lang),
          kind: LogKind.narration,
        ),
      );
    }
  }

  /// Startet die nächste Runde: Zeit vor, Weltdynamik, Karten ziehen.
  TurnReport beginTurn(GameState s) {
    if (s.isOver) return const TurnReport(pendingDecisions: []);

    s.turn += 1;
    _worldTick(s);
    _dealDeclineTick(s);

    s.log.add(
      LogEntry(
        turn: s.turn,
        label: s.turnLabel,
        title: s.lang == AppLang.de
            ? 'Lagebericht ${s.turnLabel}'
            : 'Situation report ${s.turnLabel}',
        text: _situationSummary(s),
        kind: LogKind.worldTick,
      ),
    );

    // Karten ziehen: Nachrichten sofort auflösen, Entscheidungen sammeln.
    final fireable = events.where((e) => e.canFire(s)).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    final pending = <GameEvent>[];
    for (final e in fireable) {
      if (e.isDecision) {
        if (pending.length < maxDecisionsPerTurn) {
          pending.add(e);
          s.firedEvents.add(e.id);
        }
      } else {
        s.firedEvents.add(e.id);
        _applyEffect(s, e.effect);
        s.log.add(
          LogEntry(
            turn: s.turn,
            label: s.turnLabel,
            title: e.title.t(s.lang),
            text: e.description.t(s.lang),
            kind: LogKind.narration,
          ),
        );
      }
    }

    _checkEnding(s);
    return TurnReport(pendingDecisions: s.isOver ? const [] : pending);
  }

  /// Entscheidung auflösen: W20 würfeln, Ausgang nach Gewichten bestimmen.
  Outcome resolveChoice(GameState s, GameEvent event, EventChoice choice) {
    if (!event.choices.contains(choice)) {
      throw ArgumentError.value(
        choice,
        'choice',
        'Choice does not belong to event',
      );
    }
    if (!(choice.enabledIf?.call(s) ?? true)) {
      throw StateError('Choice is locked in the current game state');
    }
    if (choice.outcomes.isEmpty ||
        choice.outcomes.any((outcome) => outcome.weight <= 0)) {
      throw StateError(
        'Every choice needs at least one positive outcome weight',
      );
    }

    final rng = _rngFor(s, _stableSalt(event.id));
    final roll = rng.nextInt(20) + 1; // W20

    // Wurf auf die Gewichtsleiste abbilden: 1 = schlechtester Bereich,
    // 20 = bester. Outcomes sind vom Autor absteigend nach Güte sortiert.
    final total = choice.outcomes.fold<int>(0, (a, o) => a + o.weight);
    final target = ((roll - 1) / 20.0 * total).floor();
    var cursor = 0;
    Outcome picked = choice.outcomes.last;
    for (final o in choice.outcomes.reversed) {
      cursor += o.weight;
      if (target < cursor) {
        picked = o;
        break;
      }
    }

    s.log.add(
      LogEntry(
        turn: s.turn,
        label: s.turnLabel,
        title: '${event.title.t(s.lang)} — ${choice.label.t(s.lang)}',
        text: choice.description.t(s.lang),
        kind: LogKind.decision,
      ),
    );

    _applyEffect(s, picked.effect);
    s.log.add(
      LogEntry(
        turn: s.turn,
        label: s.turnLabel,
        title: const LText('Ausgang', 'Outcome').t(s.lang),
        text: picked.text.t(s.lang),
        dieRoll: roll,
        kind: LogKind.outcome,
      ),
    );

    if (picked.endingId != null) {
      _setEnding(s, picked.endingId!);
    } else {
      _checkEnding(s);
    }
    return picked;
  }

  void _applyEffect(GameState s, Effect e) {
    e.deltas.forEach(s.applyDelta);
    s.flags.addAll(e.setFlags);
    s.flags.removeAll(e.clearFlags);
    if (e.newTreatyPhase != null) {
      s.treatyPhase = e.newTreatyPhase!;
      // Deal-Decline-Uhr starten, sobald ein Abkommen wirksam wird.
      if (e.newTreatyPhase == TreatyPhase.signed ||
          e.newTreatyPhase == TreatyPhase.throttle ||
          e.newTreatyPhase == TreatyPhase.pause) {
        s.dealSignedTurn ??= s.turn;
      }
    }
  }

  void _checkEnding(GameState s) {
    if (s.isOver) return;
    final id = evaluateEnding(s);
    if (id != null) _setEnding(s, id);
  }

  void _setEnding(GameState s, String id) {
    if (s.isOver) return;
    s.endingId = id;
    final ending = endings[id];
    s.log.add(
      LogEntry(
        turn: s.turn,
        label: s.turnLabel,
        title:
            ending?.title.t(s.lang) ?? const LText('Ende', 'The end').t(s.lang),
        text: ending?.description.t(s.lang) ?? '',
        kind: LogKind.ending,
      ),
    );
  }

  String _situationSummary(GameState s) {
    final us = CapabilityMilestones.labelFor(
      s.metric(Metric.usCapability),
      s.lang,
    );
    final cn = CapabilityMilestones.labelFor(
      s.metric(Metric.cnCapability),
      s.lang,
    );
    final phase = s.treatyPhase.label(s.lang);
    return s.lang == AppLang.de
        ? 'US-Frontier: $us · China: $cn · Vertragsstatus: $phase.'
        : 'US frontier: $us · China: $cn · Treaty status: $phase.';
  }
}
