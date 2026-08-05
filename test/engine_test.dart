import 'package:flutter_test/flutter_test.dart';

import 'package:cold_compute/data/directives.dart';
import 'package:cold_compute/data/scenario.dart';
import 'package:cold_compute/models/game_state.dart';
import 'package:cold_compute/models/metrics.dart';

void main() {
  test('Neue Partie startet in H2 2026', () {
    final engine = Scenario.buildEngine();
    final state = GameState.newGame(seed: 42, roleId: 'us_special_advisor');
    engine.beginTurn(state);
    expect(state.turnLabel, 'H2 2026');
    expect(state.isOver, isFalse);
  });

  test('Partie endet spätestens nach der Zeitachse', () {
    for (final role in Scenario.roles) {
      for (var seed = 1; seed <= 20; seed++) {
        final engine = Scenario.buildEngine();
        final state = GameState.newGame(seed: seed, roleId: role.id);
        role.startModifiers.forEach(state.applyDelta);
        var guard = 0;
        while (!state.isOver && guard < 60) {
          final report = engine.beginTurn(state);
          for (final event in report.pendingDecisions) {
            if (state.isOver) break;
            // Nur rollen-sichtbare Optionen; erste wählbare nehmen.
            final visible = event.choicesFor(state);
            final choice = visible.firstWhere(
              (c) => c.enabledIf?.call(state) ?? true,
              orElse: () => visible.last,
            );
            engine.resolveChoice(state, event, choice);
          }
          guard++;
        }
        expect(
          state.isOver,
          isTrue,
          reason:
              '${role.id}/Seed $seed: nach ${state.turnLabel} muss ein Ende stehen',
        );
        expect(
          Scenario.endings.containsKey(state.endingId),
          isTrue,
          reason: '${role.id}/Seed $seed: unbekanntes Ende ${state.endingId}',
        );
      }
    }
  });

  test('Alle fünf Pläne von 2029 führen zu einem gültigen Ende', () {
    for (final plan in ['Plan A', 'Plan S', 'Plan C', 'Plan B', 'Plan D']) {
      for (var seed = 1; seed <= 8; seed++) {
        final engine = Scenario.buildEngine();
        final state = GameState.newGame(
          seed: seed * 31,
          roleId: 'us_special_advisor',
        );
        var guard = 0;
        while (!state.isOver && guard < 60) {
          final report = engine.beginTurn(state);
          for (final event in report.pendingDecisions) {
            if (state.isOver) break;
            final visible = event.choicesFor(state);
            var choice = visible.firstWhere(
              (c) => c.enabledIf?.call(state) ?? true,
              orElse: () => visible.last,
            );
            if (event.id == 'choose_a_path') {
              final wanted = visible.firstWhere(
                (c) => c.label.de.startsWith(plan),
              );
              if (wanted.enabledIf?.call(state) ?? true) choice = wanted;
            }
            engine.resolveChoice(state, event, choice);
          }
          guard++;
        }
        expect(
          state.isOver,
          isTrue,
          reason: '$plan/Seed $seed: kein Ende bis ${state.turnLabel}',
        );
        expect(
          Scenario.endings.containsKey(state.endingId),
          isTrue,
          reason: '$plan/Seed $seed: unbekanntes Ende ${state.endingId}',
        );
      }
    }
  });

  test('Genau eine spielbare Rolle', () {
    expect(Scenario.roles, hasLength(1));
    expect(Scenario.roles.single.id, 'us_special_advisor');
    for (final event in Scenario.events) {
      for (final choice in event.choices) {
        expect(
          choice.roles,
          isNull,
          reason: '${event.id}: keine rollengebundenen Optionen mehr',
        );
      }
    }
  });

  test('Direktiven: Kosten, Slots und Attribution wirken', () {
    final engine = Scenario.buildEngine();
    final state = GameState.newGame(seed: 5, roleId: 'us_special_advisor');
    engine.beginTurn(state);

    final budgetBefore = state.compute;
    final sweep = directives.firstWhere((d) => d.id == 'counterintel_sweep');
    expect(engine.canRunDirective(state, sweep), isTrue);

    expect(engine.runDirective(state, sweep), isNotNull);
    expect(state.compute, closeTo(budgetBefore - sweep.computeCost, 0.001));
    expect(state.opsUsedThisTurn, sweep.slots);
    expect(state.executedDirectives, contains(sweep.id));

    // Zweite Direktive füllt die Stabskapazität des Halbjahres.
    final line = directives.firstWhere((d) => d.id == 'deconfliction_line');
    engine.runDirective(state, line);
    expect(state.opsSlotsLeft, 0);
    // Danach ist keine weitere Operation mehr möglich.
    final data = directives.firstWhere((d) => d.id == 'data_purchase');
    expect(engine.canRunDirective(state, data), isFalse);
    expect(engine.runDirective(state, data), isNull);

    // Neue Runde stellt die Kapazität wieder her und zahlt Compute aus.
    final computeBeforeTurn = state.compute;
    engine.beginTurn(state);
    expect(state.opsSlotsLeft, GameState.opsSlotsPerTurn);
    expect(state.compute, greaterThan(computeBeforeTurn));
  });

  test('Einmalige Direktiven bleiben einmalig', () {
    final engine = Scenario.buildEngine();
    final state = GameState.newGame(seed: 11, roleId: 'us_special_advisor');
    engine.beginTurn(state);
    state.compute = 600;
    final humint = directives.firstWhere((d) => d.id == 'humint_source');
    expect(humint.oneShot, isTrue);
    engine.runDirective(state, humint);
    expect(humint.isAvailable(state), isFalse);
    expect(engine.canRunDirective(state, humint), isFalse);
  });

  test('Volle Eskalation beendet die Partie im Krieg', () {
    final engine = Scenario.buildEngine();
    final state = GameState.newGame(seed: 3, roleId: 'us_special_advisor');
    engine.beginTurn(state);
    state.applyDelta(Metric.escalation, 100);
    expect(Scenario.evaluateEnding(state), 'war');
  });

  test('Direktiven-Katalog ist konsistent', () {
    final ids = directives.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
    final state = GameState.newGame(seed: 1, roleId: 'us_special_advisor');
    for (final d in directives) {
      expect(d.computeCost, greaterThan(0), reason: '${d.id}: Kosten');
      expect(d.slots, inInclusiveRange(1, GameState.opsSlotsPerTurn),
          reason: '${d.id}: Slots');
      expect(d.successChance(state), inInclusiveRange(5, 95));
      expect(d.exposureChance(state), inInclusiveRange(0, 95));
    }
  });

  test('Spielstand übersteht JSON-Roundtrip', () {
    final engine = Scenario.buildEngine();
    final state = GameState.newGame(seed: 99, roleId: 'us_special_advisor');
    engine.beginTurn(state);
    final restored = GameState.fromJson(state.toJson());
    expect(restored.turn, state.turn);
    expect(restored.metrics, state.metrics);
    expect(restored.treatyPhase, state.treatyPhase);
    expect(restored.log.length, state.log.length);
    expect(restored.pendingEventIds, state.pendingEventIds);
  });

  test('Szenario-IDs und Outcome-Gewichte sind gültig', () {
    final engine = Scenario.buildEngine();
    final ids = engine.events.map((event) => event.id).toList();
    expect(
      ids.toSet().length,
      ids.length,
      reason: 'Event-IDs müssen eindeutig sein',
    );
    for (final event in engine.events) {
      expect(
        event.minTurn,
        lessThanOrEqualTo(event.maxTurn),
        reason: '${event.id}: ungültiges Zeitfenster',
      );
      for (final choice in event.choices) {
        expect(
          choice.outcomes,
          isNotEmpty,
          reason: '${event.id}: Choice ohne Outcome',
        );
        expect(
          choice.outcomes.every((outcome) => outcome.weight > 0),
          isTrue,
          reason: '${event.id}: Gewichte müssen positiv sein',
        );
        for (final outcome in choice.outcomes) {
          if (outcome.endingId != null) {
            expect(
              Scenario.endings,
              contains(outcome.endingId),
              reason: '${event.id}: unbekanntes Ende ${outcome.endingId}',
            );
          }
        }
      }
    }
  });
}
