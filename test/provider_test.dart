import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cold_compute/providers/game_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<GameProvider> gameAtDecision() async {
    final provider = GameProvider();
    await provider.init();
    await provider.newGame(roleId: 'us_special_advisor', seed: 42);
    for (
      var guard = 0;
      guard < 12 && provider.currentDecision == null;
      guard++
    ) {
      await provider.nextTurn();
    }
    expect(provider.currentDecision, isNotNull);
    return provider;
  }

  test('Fortsetzen erhält eine noch offene Entscheidung', () async {
    final original = await gameAtDecision();
    final eventId = original.currentDecision!.id;
    final turn = original.state!.turn;

    final restored = GameProvider();
    await restored.init();
    expect(await restored.continueGame(), isTrue);

    expect(restored.state!.turn, turn);
    expect(restored.currentDecision?.id, eventId);
    expect(restored.state!.pendingEventIds, contains(eventId));
  });

  test(
    'Fortsetzen wendet ein bereits gewürfeltes Ergebnis nicht doppelt an',
    () async {
      final original = await gameAtDecision();
      final event = original.currentDecision!;
      final choice = event.choices.firstWhere(
        (candidate) => candidate.enabledIf?.call(original.state!) ?? true,
      );
      await original.choose(choice);
      final metricsAfterRoll = Map.of(original.state!.metrics);
      final logLengthAfterRoll = original.state!.log.length;
      final resolvedEventId = event.id;

      final restored = GameProvider();
      await restored.init();
      expect(await restored.continueGame(), isTrue);

      expect(restored.state!.metrics, metricsAfterRoll);
      expect(restored.state!.log.length, logLengthAfterRoll);
      expect(restored.state!.resolvedPendingEventId, isNull);
      expect(restored.state!.pendingEventIds, isNot(contains(resolvedEventId)));
    },
  );

  test('Parallele Weiter-Taps überspringen keine Runde', () async {
    final provider = GameProvider();
    await provider.init();
    await provider.newGame(roleId: 'us_special_advisor', seed: 7);
    expect(provider.currentDecision, isNull);
    final before = provider.state!.turn;

    await Future.wait([provider.nextTurn(), provider.nextTurn()]);

    expect(provider.state!.turn, before + 1);
  });

  test('Sound-Einstellung bleibt appübergreifend erhalten', () async {
    final provider = GameProvider();
    await provider.init();
    await provider.setSoundEnabled(false);

    final restored = GameProvider();
    await restored.init();
    expect(restored.soundEnabled, isFalse);
  });
}
