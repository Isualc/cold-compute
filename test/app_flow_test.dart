import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cold_compute/main.dart';
import 'package:cold_compute/widgets/world_map.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Endlos-Animation der Lagekarte aus, damit pumpAndSettle terminiert.
    WorldSituationMap.loopAnimation = false;
  });

  testWidgets(
    'Startscreen → neue Partie → Runden spielen bis zur Entscheidung',
    (tester) async {
      await tester.pumpWidget(const ColdComputeApp());
      await tester.pumpAndSettle();

      // Startscreen
      expect(find.text('COLD\nCOMPUTE'), findsOneWidget);
      expect(find.text('Neue Partie beginnen'), findsOneWidget);
      expect(
        find.text('KI-Sonderberater:in des Weißen Hauses'),
        findsOneWidget,
      );

      final newGame = find.byKey(const ValueKey('new_game_button'));
      await tester.ensureVisible(newGame);
      await tester.tap(newGame);
      await tester.pumpAndSettle();

      // GameScreen, Runde H2 2026
      expect(find.text('H2 2026'), findsWidgets);

      // Der Briefing-Bereich liegt in derselben Seite unter der Lagekarte.
      final page = find.descendant(
        of: find.byKey(const PageStorageKey('mobile_command_center')),
        matching: find.byType(Scrollable),
      );

      // Vom Seitenkopf nach unten scrollen, bis das Briefing im Blick ist:
      // entweder eine Entscheidungskarte oder der Weiter-Button.
      Future<bool> scrollToBriefing() async {
        await tester.drag(page, const Offset(0, 2500));
        await tester.pumpAndSettle();
        for (var step = 0; step < 8; step++) {
          if (find.textContaining('ENTSCHEIDUNG ·').evaluate().isNotEmpty) {
            return true;
          }
          if (find
              .byKey(const ValueKey('next_turn_button'))
              .evaluate()
              .isNotEmpty) {
            return false;
          }
          await tester.drag(page, const Offset(0, -260));
          await tester.pumpAndSettle();
        }
        return find.textContaining('ENTSCHEIDUNG ·').evaluate().isNotEmpty;
      }

      // Runden weiterklicken, bis eine Entscheidungskarte auftaucht.
      var foundDecision = false;
      for (var i = 0; i < 10 && !foundDecision; i++) {
        foundDecision = await scrollToBriefing();
        if (foundDecision) break;
        final next = find.byKey(const ValueKey('next_turn_button'));
        if (next.evaluate().isEmpty) break;
        await tester.tap(next, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
      expect(
        foundDecision,
        isTrue,
        reason: 'Binnen 10 Runden muss eine Entscheidungskarte erscheinen',
      );

      // Erste wählbare Option anklicken → W20-Ergebnis → Weiter.
      final choice = find.byKey(const ValueKey('choice_0'));
      await tester.scrollUntilVisible(choice, 200, scrollable: page);
      await tester.pumpAndSettle();
      await tester.tap(choice);
      await tester.pumpAndSettle();

      // Die Ergebnisanzeige steht an derselben Stelle der Seite.
      await tester.drag(page, const Offset(0, 2500));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Weiter'),
        260,
        scrollable: page,
      );
      expect(find.text('W20'), findsOneWidget);
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Sprachwahl Englisch: Startscreen und Partie auf Englisch', (
    tester,
  ) async {
    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();

    // Sprachumschalter: English wählen.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('THE RACE FOR SUPERINTELLIGENCE'), findsOneWidget);
    expect(find.text('Start a new game'), findsOneWidget);
    expect(
      find.text('White House AI Advisor'),
      findsOneWidget,
    );

    final newGame = find.byKey(const ValueKey('new_game_button'));
    await tester.ensureVisible(newGame);
    await tester.tap(newGame);
    await tester.pumpAndSettle();

    // Partie läuft auf Englisch: Vertragsstatus, Weltlage, Runden-Button.
    expect(find.text('No treaty'), findsOneWidget);
    expect(find.text('WORLD STATE'), findsOneWidget);

    final page = find.descendant(
      of: find.byKey(const PageStorageKey('mobile_command_center')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Next half-year'),
      300,
      scrollable: page,
    );
    expect(find.text('Next half-year'), findsOneWidget);
  });

  testWidgets('Codex öffnet mit Regelwerk und Quellen', (tester) async {
    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();

    final codex = find.byKey(const ValueKey('codex_button'));
    await tester.ensureVisible(codex);
    await tester.tap(codex);
    await tester.pumpAndSettle();

    expect(find.text('Das Szenario: AI 2040 — Plan A'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Die fünf Pläne von 2029'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    expect(find.text('Die fünf Pläne von 2029'), findsOneWidget);
  });

  testWidgets('Statistik zeigt Bilanz und Historie', (tester) async {
    SharedPreferences.setMockInitialValues({
      'coldcompute_history_v1': jsonEncode([
        {
          'endedAt': '2026-08-01T20:15:00.000',
          'roleId': 'us_special_advisor',
          'planPath': 'A',
          'endingId': 'plan_a_success',
          'turnLabel': 'H2 2040',
          'year': 2040,
          'lang': 'de',
          'alignment': 82,
          'trust': 74,
          'verification': 66,
          'decisions': 11,
          'seed': 1,
        },
        {
          'endedAt': '2026-08-02T21:40:00.000',
          'roleId': 'lab_ceo',
          'planPath': 'D',
          'endingId': 'race_takeover',
          'turnLabel': 'H1 2031',
          'year': 2031,
          'lang': 'de',
          'alignment': 20,
          'trust': 12,
          'verification': 9,
          'decisions': 4,
          'seed': 2,
        },
      ]),
    });

    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();

    final stats = find.byKey(const ValueKey('stats_button'));
    await tester.ensureVisible(stats);
    await tester.pumpAndSettle();
    await tester.tap(stats, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('2 Partien'), findsOneWidget);
    expect(find.text('50 %'), findsOneWidget); // Lichtkegel-Quote
    expect(find.text('Der Lichtkegel'), findsWidgets);
    expect(find.text('Das Rennen endet — ohne uns'), findsWidgets);
    expect(find.text('Historie löschen'), findsOneWidget);
  });

  testWidgets('Mobil: Ops-Direktive kostet Compute und einen Slot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();
    final newGame = find.byKey(const ValueKey('new_game_button'));
    await tester.ensureVisible(newGame);
    await tester.tap(newGame);
    await tester.pumpAndSettle();

    final page = find.descendant(
      of: find.byKey(const PageStorageKey('mobile_command_center')),
      matching: find.byType(Scrollable),
    );

    // Einsatzzentrale liegt in derselben Seite weiter unten.
    final opsHeader = find.text('VERDECKTE OPERATIONEN');
    await tester.scrollUntilVisible(opsHeader, 260, scrollable: page);
    expect(find.text('2/2'), findsOneWidget); // freie Operationsslots

    final falseFlag = find.byKey(const ValueKey('directive_false_flag'));
    await tester.scrollUntilVisible(falseFlag, 260, scrollable: page);
    expect(find.text('False-Flag-Operation'), findsOneWidget);

    final sweep = find.byKey(const ValueKey('directive_counterintel_sweep'));
    await tester.scrollUntilVisible(sweep, 260, scrollable: page);
    await tester.pumpAndSettle();
    expect(
      tester.widget<OutlinedButton>(sweep).onPressed,
      isNotNull,
      reason: 'Die Direktive muss bezahlbar und anordenbar sein',
    );
    await tester.tap(sweep);
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(opsHeader, page, const Offset(0, 320));
    await tester.pumpAndSettle();

    // Einsatzbericht erscheint, ein Slot ist verbraucht.
    expect(find.text('EINSATZBERICHT'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('Mobil zeigt Karte, Metriken, Briefing, Ops und Chronik', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();
    final newGame = find.byKey(const ValueKey('new_game_button'));
    await tester.ensureVisible(newGame);
    await tester.tap(newGame);
    await tester.pumpAndSettle();

    // Karte und Weltlage stehen ohne Umweg oben auf der Seite.
    expect(find.byType(WorldSituationMap), findsOneWidget);
    expect(find.text('WELTLAGE'), findsOneWidget);
    // Alarmstufe der Militärlage wird auf der Karte angezeigt.
    expect(find.textContaining('STUFE '), findsOneWidget);
    expect(find.text('Militärlage'.toUpperCase()), findsOneWidget);

    final page = find.descendant(
      of: find.byKey(const PageStorageKey('mobile_command_center')),
      matching: find.byType(Scrollable),
    );

    // Weiter unten in derselben Seite: Operationen und Protokoll.
    await tester.scrollUntilVisible(
      find.text('VERDECKTE OPERATIONEN'),
      260,
      scrollable: page,
    );
    await tester.scrollUntilVisible(
      find.text('PROTOKOLL'),
      260,
      scrollable: page,
    );
    expect(find.text('PROTOKOLL'), findsOneWidget);
  });

  testWidgets('Desktop: Chronik startet eingeklappt und öffnet per Kopfzeile', (
    tester,
  ) async {
    // 1600 px Breite: Desktop-Layout UND aktiver UI-Zoom (1600/1440 ≈ 1,11).
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ColdComputeApp());
    await tester.pumpAndSettle();

    final newGame = find.byKey(const ValueKey('new_game_button'));
    await tester.ensureVisible(newGame);
    await tester.tap(newGame);
    await tester.pumpAndSettle();

    // Kommandozentrale: Ops-Spalte sichtbar, Chronik nur als Kopfzeile.
    expect(find.text('VERDECKTE OPERATIONEN'), findsOneWidget);
    expect(find.text('PROTOKOLL'), findsOneWidget);
    expect(find.byKey(const PageStorageKey('chronicle')), findsNothing);

    // Tap auf die Kopfzeile öffnet die volle Chronik, zweiter Tap schließt.
    await tester.tap(find.text('PROTOKOLL'));
    await tester.pumpAndSettle();
    expect(find.byKey(const PageStorageKey('chronicle')), findsOneWidget);

    await tester.tap(find.text('PROTOKOLL'));
    await tester.pumpAndSettle();
    expect(find.byKey(const PageStorageKey('chronicle')), findsNothing);
  });
}
