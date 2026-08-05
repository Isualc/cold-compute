import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cold_compute/models/game_state.dart';
import 'package:cold_compute/models/metrics.dart';
import 'package:cold_compute/theme.dart';
import 'package:cold_compute/widgets/world_map.dart';

void main() {
  setUp(() {
    WorldSituationMap.loopAnimation = false;
  });

  Future<void> pumpMap(WidgetTester tester, double escalation) async {
    final state = GameState.newGame(seed: 1, roleId: 'us_special_advisor')
      ..turn = 6;
    state.metrics[Metric.escalation] = escalation;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          // Wie in der App: die Karte lebt in einer scrollenden Liste,
          // also keine feste Höhe erzwingen.
          body: ListView(
            children: [
              WorldSituationMap(state: state, height: 180),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Karte zeigt Friedenslage bei niedriger Eskalation', (
    tester,
  ) async {
    await pumpMap(tester, 10);
    expect(find.textContaining('STUFE 1'), findsOneWidget);
    expect(find.textContaining('Friedenslage'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Karte eskaliert bis zur Kriegsgefahr', (tester) async {
    const steps = <(double, String)>[
      (35, 'STUFE 2'),
      (50, 'STUFE 3'),
      (70, 'STUFE 4'),
      (92, 'STUFE 5'),
    ];
    for (final (escalation, stage) in steps) {
      await pumpMap(tester, escalation);
      expect(
        find.textContaining(stage),
        findsOneWidget,
        reason: 'Eskalation $escalation muss $stage zeigen',
      );
      // Konfliktachse, Brennpunkte und Alarmrahmen müssen fehlerfrei malen.
      expect(tester.takeException(), isNull);
    }
  });
}
