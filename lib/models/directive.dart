import 'game_event.dart';
import 'game_state.dart';
import 'lang.dart';
import 'metrics.dart';

/// Einsatzarten der verdeckten Operationen — die Domänen eines
/// Nachrichtendienst- und Militärstabs.
enum OpsDomain { intel, cyber, kinetic, deception, procurement, defensive, diplomatic }

extension OpsDomainInfo on OpsDomain {
  LText get label => switch (this) {
        OpsDomain.intel => const LText('Aufklärung', 'Intelligence'),
        OpsDomain.cyber => const LText('Cyber', 'Cyber'),
        OpsDomain.kinetic => const LText('Verdeckte Aktion', 'Covert action'),
        OpsDomain.deception => const LText('Täuschung', 'Deception'),
        OpsDomain.procurement => const LText('Beschaffung', 'Procurement'),
        OpsDomain.defensive => const LText('Abwehr', 'Counterintelligence'),
        OpsDomain.diplomatic => const LText('Diplomatie', 'Diplomacy'),
      };

  /// Kürzel für die Einsatzkarte.
  String get code => switch (this) {
        OpsDomain.intel => 'INT',
        OpsDomain.cyber => 'CYB',
        OpsDomain.kinetic => 'COV',
        OpsDomain.deception => 'DEC',
        OpsDomain.procurement => 'PRO',
        OpsDomain.defensive => 'DEF',
        OpsDomain.diplomatic => 'DIP',
      };
}

/// Ausgang einer Direktive. [exposed] markiert Ergebnisse, bei denen die
/// Operation der eigenen Seite zugerechnet wurde (Attribution).
class DirectiveOutcome {
  final LText text;
  final Effect effect;
  final bool exposed;

  /// Direkte Compute-Änderung in K H100e (Beschaffung, Verluste).
  final double computeDelta;

  const DirectiveOutcome({
    required this.text,
    this.effect = Effect.none,
    this.exposed = false,
    this.computeDelta = 0,
  });
}

/// Eine verdeckte Operation, die pro Halbjahr angeordnet werden kann.
class Directive {
  final String id;
  final OpsDomain domain;
  final LText name;
  final LText description;

  /// Kosten in K H100e — Compute ist die Währung dieses Szenarios.
  final double computeCost;

  /// Verbrauchte Operationsslots (Stabskapazität) pro Halbjahr.
  final int slots;

  /// Basis-Erfolgschance in Prozent, bevor Aufklärungslage und
  /// gegnerisches Verifikationsregime gegengerechnet werden.
  final int baseSuccess;

  /// Basis-Attributionsrisiko in Prozent (Wahrscheinlichkeit, dass ein
  /// Misserfolg der eigenen Seite zugeordnet wird).
  final int baseExposure;

  /// Nur einmal pro Partie ausführbar.
  final bool oneShot;

  /// Zusätzliche Verfügbarkeitsbedingung (Vertragsphase, Flags, Jahr).
  final bool Function(GameState state)? available;

  /// Hinweis, warum die Direktive gerade gesperrt ist.
  final LText? lockedHint;

  final DirectiveOutcome success;
  final DirectiveOutcome failure;

  const Directive({
    required this.id,
    required this.domain,
    required this.name,
    required this.description,
    required this.computeCost,
    required this.baseSuccess,
    required this.baseExposure,
    required this.success,
    required this.failure,
    this.slots = 1,
    this.oneShot = false,
    this.available,
    this.lockedHint,
  });

  bool isAvailable(GameState s) {
    if (oneShot && s.executedDirectives.contains(id)) return false;
    return available?.call(s) ?? true;
  }

  /// Erfolgschance in der aktuellen Lage: gute Aufklärung hilft, ein
  /// scharfes gegnerisches Verifikationsregime erschwert verdeckte Arbeit.
  int successChance(GameState s) {
    final intelBonus = ((s.metric(Metric.intel) - 35) * .25).round();
    final verificationMalus = switch (domain) {
      OpsDomain.cyber ||
      OpsDomain.kinetic ||
      OpsDomain.deception ||
      OpsDomain.procurement =>
        (s.metric(Metric.verification) * .18).round(),
      _ => 0,
    };
    return (baseSuccess + intelBonus - verificationMalus).clamp(5, 95);
  }

  /// Attributionsrisiko in der aktuellen Lage.
  int exposureChance(GameState s) {
    final verificationMalus = switch (domain) {
      OpsDomain.intel || OpsDomain.defensive || OpsDomain.diplomatic => 0,
      _ => (s.metric(Metric.verification) * .22).round(),
    };
    final intelBonus = ((s.metric(Metric.intel) - 35) * .12).round();
    return (baseExposure + verificationMalus - intelBonus).clamp(0, 95);
  }
}
