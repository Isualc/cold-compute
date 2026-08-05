import 'game_state.dart';
import 'lang.dart';
import 'metrics.dart';

/// Wirkung einer Entscheidung oder eines Ereignisses auf die Weltlage.
class Effect {
  final Map<Metric, double> deltas;
  final Set<String> setFlags;
  final Set<String> clearFlags;
  final TreatyPhase? newTreatyPhase;

  const Effect({
    this.deltas = const {},
    this.setFlags = const {},
    this.clearFlags = const {},
    this.newTreatyPhase,
  });

  static const Effect none = Effect();
}

/// Ein möglicher Ausgang einer Entscheidung. Die Engine würfelt (W20),
/// gewichtet nach [weight] und Lage-Modifikatoren.
class Outcome {
  final int weight;
  final LText text;
  final Effect effect;

  /// Optional: löst direkt ein Ende aus (Ending-Id).
  final String? endingId;

  const Outcome({
    required this.weight,
    required this.text,
    this.effect = Effect.none,
    this.endingId,
  });
}

/// Eine Handlungsoption des Spielers zu einem Ereignis.
class EventChoice {
  final LText label;
  final LText description;
  final List<Outcome> outcomes;

  /// Bedingung, unter der die Option überhaupt wählbar ist.
  final bool Function(GameState state)? enabledIf;

  /// Kurzer Hinweis, warum die Option gesperrt ist.
  final LText? lockedHint;

  /// Nur für diese Rollen sichtbar. Null = für alle Rollen.
  final Set<String>? roles;

  const EventChoice({
    required this.label,
    required this.description,
    required this.outcomes,
    this.enabledIf,
    this.lockedHint,
    this.roles,
  });

  bool visibleFor(GameState state) =>
      roles == null || roles!.contains(state.roleId);
}

/// Ereigniskarte des Szenarios: Nachricht oder Entscheidungspunkt.
class GameEvent {
  final String id;
  final LText title;

  /// Lagebericht / Erzähltext (Pen-and-Paper: das, was der Spielleiter vorliest).
  final LText description;

  /// Quelle im Regelwerk, z. B. 'AI 2040 Kap. 2029' — für den Codex.
  final LText? source;

  /// Frühester und spätester Zeitpunkt (Rundenindex), zu dem die Karte
  /// gezogen werden kann.
  final int minTurn;
  final int maxTurn;

  /// Zusätzliche Bedingung an die Weltlage.
  final bool Function(GameState state)? trigger;

  /// Höhere Priorität wird zuerst gezogen.
  final int priority;

  /// Entscheidungsoptionen. Leer = reine Nachrichtenkarte.
  final List<EventChoice> choices;

  /// Wirkung einer reinen Nachrichtenkarte.
  final Effect effect;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    this.source,
    required this.minTurn,
    required this.maxTurn,
    this.trigger,
    this.priority = 0,
    this.choices = const [],
    this.effect = Effect.none,
  });

  bool get isDecision => choices.isNotEmpty;

  /// Optionen, die die aktuelle Rolle sehen darf.
  List<EventChoice> choicesFor(GameState state) =>
      choices.where((c) => c.visibleFor(state)).toList();

  bool canFire(GameState state) {
    if (state.turn < minTurn || state.turn > maxTurn) return false;
    if (state.firedEvents.contains(id)) return false;
    final t = trigger;
    if (t != null && !t(state)) return false;
    return true;
  }
}
