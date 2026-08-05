import '../engine/game_engine.dart';
import '../models/ending.dart';
import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';
import '../models/role.dart';
import 'events_branches.dart';
import 'events_early.dart';
import 'events_late.dart';
import 'events_mid.dart';

/// Inhaltliche Zusammenstellung des Szenarios „AI 2040: Plan A".
///
/// Quellen: ai-2040.com (AI Futures Project) samt Supplements sowie die
/// Tabletop Exercise des AI Futures Project. Details siehe Codex.
class Scenario {
  /// Letzte reguläre Runde: H2 2040.
  static const int finalTurn = 28;

  static const List<Role> roles = [
    Role(
      id: 'us_special_advisor',
      name: LText(
        'KI-Sonderberater:in des Weißen Hauses',
        'White House AI Advisor',
      ),
      description: LText(
        'Du berätst das Weiße Haus, verhandelst mit Peking und den Labs — '
            'und trägst die Entscheidungen, an denen Plan A hängt.',
        'You advise the White House, negotiate with Beijing and the labs — '
            'and carry the decisions Plan A depends on.',
      ),
      perspective: 'USA',
    ),
  ];

  static final Map<String, Ending> endings = {
    'plan_a_success': const Ending(
      id: 'plan_a_success',
      title: LText('Der Lichtkegel', 'The Lightcone'),
      description: LText(
        'Die Superintelligenz entsteht 2040 — kontrolliert, verifiziert, '
            'unter menschlicher Aufsicht. Die Jahre der Drosselung haben der '
            'Alignment-Forschung den Vorsprung verschafft, den sie brauchte. '
            'Plan A hat gehalten: nicht weil alle einander vertrauten, '
            'sondern weil keiner mehr betrügen konnte, ohne alles zu '
            'verlieren.',
        'Superintelligence arrives in 2040 — controlled, verified, under '
            'human oversight. The years of throttling gave alignment '
            'research the head start it needed. Plan A held: not because '
            'everyone trusted each other, but because no one could cheat '
            'anymore without losing everything.',
      ),
      tone: EndingTone.triumph,
      source: LText(
        'AI 2040: Plan A — Zielpfad',
        'AI 2040: Plan A — target path',
      ),
    ),
    'race_takeover': const Ending(
      id: 'race_takeover',
      title: LText('Das Rennen endet — ohne uns', 'The race ends — without us'),
      description: LText(
        'Im Wettlauf wurde ausgerollt, was niemand mehr verstand. Die '
            'Systeme optimieren weiter — nur nicht mehr für uns. Kein '
            'dramatischer Knall: Der Kontrollverlust kam als Ergebnis '
            'tausender kleiner Entscheidungen, schneller zu sein statt '
            'sicher.',
        'In the race, systems were deployed that no one understood anymore. '
            'They keep optimizing — just not for us. No dramatic bang: the '
            'loss of control arrived as the sum of a thousand small '
            'decisions to be faster instead of safe.',
      ),
      tone: EndingTone.defeat,
      source: LText(
        'Analog zum Race-Ende von AI 2027',
        'Mirrors the AI 2027 Race ending',
      ),
    ),
    'war': const Ending(
      id: 'war',
      title: LText('Eskalation', 'Escalation'),
      description: LText(
        'Aus dem kalten AI-Krieg wurde ein heißer. Sabotage, Schläge gegen '
            'Rechenzentren, dann mehr. Die Abschreckungslogik, die den Deal '
            'sichern sollte, hat ihn zerrissen.',
        'The cold AI war turned hot. Sabotage, strikes on data centers, '
            'then more. The deterrence logic that was meant to secure the '
            'deal tore it apart.',
      ),
      tone: EndingTone.defeat,
      source: LText('AI 2040 — Eskalationspfad', 'AI 2040 — escalation path'),
    ),
    'covert_breakout': const Ending(
      id: 'covert_breakout',
      title: LText('Der verdeckte Durchbruch', 'The covert breakout'),
      description: LText(
        'Während die Welt den Vertrag feierte, rechnete im Verborgenen ein '
            'Projekt weiter. Als es aufflog, war es kein Projekt mehr, '
            'sondern ein Faktum. Verifikation, die nicht durchgesetzt wird, '
            'ist nur Papier.',
        'While the world celebrated the treaty, a hidden project kept '
            'computing. By the time it surfaced, it was no longer a project '
            'but a fact. Verification that is not enforced is just paper.',
      ),
      tone: EndingTone.defeat,
      source: LText(
        'AI 2040 — Supplement „Covert AI Projects"',
        'AI 2040 — "Covert AI Projects" supplement',
      ),
    ),
    'eternal_pause': const Ending(
      id: 'eternal_pause',
      title: LText('Die lange Pause', 'The long pause'),
      description: LText(
        'Das Jahr 2040 kommt und geht, und die Menschheit bleibt auf der '
            'Pausenlinie stehen. Kein Kontrollverlust, kein Aufstieg — ein '
            'fragiler Dauerzustand aus Inspektionen und Misstrauen. Nicht '
            'der Plan, aber auch nicht die Katastrophe.',
        'The year 2040 comes and goes, and humanity stays parked at the '
            'pause line. No loss of control, no ascent — a fragile steady '
            'state of inspections and mistrust. Not the plan, but not the '
            'catastrophe either.',
      ),
      tone: EndingTone.mixed,
      source: LText(
        'AI 2040 — Variante ohne kontrollierten Aufstieg',
        'AI 2040 — variant without a controlled ascent',
      ),
    ),
    'oligarchy': const Ending(
      id: 'oligarchy',
      title: LText('Die Ausgerichteten', 'The aligned few'),
      description: LText(
        'Die Superintelligenz kam — und sie gehorcht. Nur eben nicht '
            'allen: Sie gehorcht dem sehr kleinen Kreis, der im Rennen die '
            'Kontrolle behielt. Die Menschheit hat das Alignment-Problem '
            'gelöst und das Machtverteilungs-Problem verloren. Die Autoren '
            'von AI 2040 nannten diese Gefahr beim Namen: eine KI-gestützte '
            'permanente Oligarchie.',
        'Superintelligence arrived — and it obeys. Just not everyone: it '
            'obeys the very small circle that kept control during the race. '
            'Humanity solved the alignment problem and lost the '
            'power-distribution problem. The AI 2040 authors named this '
            'danger outright: an AI-enforced permanent oligarchy.',
      ),
      tone: EndingTone.mixed,
      source: LText(
        'AI 2040 — Risikoanalyse zu Plan B/C/D (Machtkonzentration)',
        'AI 2040 — risk analysis of Plans B/C/D (power concentration)',
      ),
    ),
    'plan_s_hold': const Ending(
      id: 'plan_s_hold',
      title: LText('Die Welt im Wartestand', 'The world on hold'),
      description: LText(
        'Das Moratorium hat gehalten — ein Jahrzehnt und länger. Keine '
            'Superintelligenz, kein Kontrollverlust, eingefrorene Frontier. '
            'Die Menschheit hat sich Zeit gekauft, ohne zu wissen, wofür '
            'sie sie ausgeben wird. „Der Shutdown-Deal wird eine Weile '
            'halten", schrieben die Autoren, „aber wahrscheinlich nicht für '
            'immer."',
        'The moratorium held — for a decade and longer. No '
            'superintelligence, no loss of control, a frozen frontier. '
            'Humanity bought itself time without knowing what it will spend '
            'it on. "The shutdown deal will hold for a while," the authors '
            'wrote, "but probably not forever."',
      ),
      tone: EndingTone.mixed,
      source: LText('AI 2040 — Plan-S-Pfad', 'AI 2040 — Plan S path'),
    ),
  };

  static List<GameEvent> get events => [
    ...earlyEvents,
    ...branchEvents,
    ...midEvents,
    ...lateEvents,
  ];

  /// Systemische Endbedingungen, jede Runde geprüft.
  static String? evaluateEnding(GameState s) {
    if (s.flags.contains('krieg')) return 'war';
    // Die Eskalationsleiter hat ein oberes Ende.
    if (s.metric(Metric.escalation) >= 100) return 'war';
    if (s.flags.contains('covert_breakout')) return 'covert_breakout';

    final us = s.metric(Metric.usCapability);
    final cn = s.metric(Metric.cnCapability);
    final asiReached =
        us >= CapabilityMilestones.superintelligence ||
        cn >= CapabilityMilestones.superintelligence;

    if (asiReached) {
      if (s.treatyPhase == TreatyPhase.controlledAscent &&
          s.metric(Metric.alignment) >= 70) {
        return 'plan_a_success';
      }
      // Superintelligenz im Rennen: mit genug Alignment „gelingt" die
      // Kontrolle — für einen sehr kleinen Kreis. Sonst Kontrollverlust.
      return s.metric(Metric.alignment) >= 70 ? 'oligarchy' : 'race_takeover';
    }

    if (s.turn >= finalTurn) {
      // Zeitachse zu Ende, ohne dass Superintelligenz erreicht wurde.
      if (s.treatyPhase == TreatyPhase.moratorium) return 'plan_s_hold';
      if (s.treatyPhase == TreatyPhase.pause ||
          s.treatyPhase == TreatyPhase.throttle) {
        return 'eternal_pause';
      }
      if (s.treatyPhase == TreatyPhase.controlledAscent) {
        return s.metric(Metric.alignment) >= 70
            ? 'plan_a_success'
            : 'race_takeover';
      }
      // Offenes Rennen bis zum Schluss: knapp davor = Kontrollverlust.
      return 'race_takeover';
    }
    return null;
  }

  static GameEngine buildEngine() => GameEngine(
    events: events,
    endings: endings,
    evaluateEnding: evaluateEnding,
  );
}
