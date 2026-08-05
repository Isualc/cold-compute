import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cold_compute/models/game_record.dart';
import 'package:cold_compute/providers/game_provider.dart';
import 'package:cold_compute/services/history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Plan-Pfad wird korrekt aus Flags abgeleitet', () {
    expect(GameRecord.planPathFromFlags({'plan_a'}), 'A');
    expect(GameRecord.planPathFromFlags({'plan_d'}), 'D');
    expect(GameRecord.planPathFromFlags({'plan_b', 'plan_a'}), 'B→A');
    expect(GameRecord.planPathFromFlags({'plan_s', 'plan_a'}), 'S→A');
    expect(GameRecord.planPathFromFlags({'vertrag_voll'}), '—');
  });

  test('HistoryService speichert, lädt und deckelt', () async {
    for (var i = 0; i < HistoryService.maxEntries + 5; i++) {
      await HistoryService.add(GameRecord(
        endedAtIso: DateTime(2026, 8, 3, 12, i % 60).toIso8601String(),
        roleId: 'us_special_advisor',
        planPath: 'A',
        endingId: 'plan_a_success',
        turnLabel: 'H2 2040',
        year: 2040,
        langName: 'de',
        alignment: 80,
        trust: 70,
        verification: 60,
        decisions: i,
        seed: i,
      ));
    }
    final loaded = await HistoryService.load();
    expect(loaded.length, HistoryService.maxEntries);
    // Neueste zuerst: der letzte Eintrag hat die höchste Entscheidungszahl.
    expect(loaded.first.decisions, HistoryService.maxEntries + 4);

    await HistoryService.clear();
    expect(await HistoryService.load(), isEmpty);
  });

  test('GameRecord übersteht JSON-Roundtrip', () async {
    final record = GameRecord(
      endedAtIso: DateTime(2040, 12, 1).toIso8601String(),
      roleId: 'lab_ceo',
      planPath: 'B→A',
      endingId: 'oligarchy',
      turnLabel: 'H1 2038',
      year: 2038,
      langName: 'en',
      alignment: 71,
      trust: 40,
      verification: 55,
      decisions: 9,
      seed: 4711,
    );
    final restored = GameRecord.fromJson(record.toJson());
    expect(restored.endedAtIso, record.endedAtIso);
    expect(restored.roleId, record.roleId);
    expect(restored.planPath, record.planPath);
    expect(restored.endingId, record.endingId);
    expect(restored.turnLabel, record.turnLabel);
    expect(restored.decisions, record.decisions);
  });

  test('Eine komplette Partie landet genau einmal in der Statistik',
      () async {
    final provider = GameProvider();
    await provider.init();
    expect(provider.history, isEmpty);

    await provider.newGame(roleId: 'us_special_advisor', seed: 7);
    var guard = 0;
    while (!(provider.state?.isOver ?? true) && guard < 400) {
      final decision = provider.currentDecision;
      if (decision != null) {
        if (provider.lastOutcome != null) {
          await provider.acknowledgeOutcome();
        } else {
          final visible = decision.choicesFor(provider.state!);
          final choice = visible.firstWhere(
            (c) => c.enabledIf?.call(provider.state!) ?? true,
            orElse: () => visible.last,
          );
          await provider.choose(choice);
        }
      } else {
        await provider.nextTurn();
      }
      guard++;
    }

    expect(provider.state?.isOver, isTrue,
        reason: 'Die Partie muss in ein Ende laufen');
    expect(provider.history.length, 1,
        reason: 'Genau ein Statistik-Eintrag pro Partie');
    expect(await HistoryService.load(), hasLength(1));

    // Weiteres Persistieren derselben Partie erzeugt keinen Doppeleintrag.
    await provider.acknowledgeOutcome();
    expect(provider.history.length, 1);

    final record = provider.history.first;
    expect(record.endingId, provider.state!.endingId);
    expect(record.roleId, 'us_special_advisor');
  });
}
