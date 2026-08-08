import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cold_compute/models/game_state.dart';
import 'package:cold_compute/models/lang.dart';
import 'package:cold_compute/theme.dart';
import 'package:cold_compute/widgets/log_panel.dart';

void main() {
  const entries = [
    LogEntry(
      turn: 0,
      label: 'H2 2026',
      title: 'Erster Lagebericht',
      text: 'Die Weltlage verschiebt sich.',
      kind: LogKind.worldTick,
    ),
    LogEntry(
      turn: 1,
      label: 'H1 2027',
      title: 'Zweiter Lagebericht',
      text: 'Compute wird knapp.',
    ),
  ];

  testWidgets('Eingeklappte Chronik zeigt nur die Kopfzeile, Tap öffnet sie', (
    tester,
  ) async {
    var collapsed = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ListView(
              children: [
                LogPanel(
                  entries: entries,
                  lang: AppLang.de,
                  embedded: true,
                  collapsible: true,
                  collapsed: collapsed,
                  onToggle: () => setState(() => collapsed = !collapsed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Eingeklappt: Kopfzeile mit Zähler, aber keine Einträge.
    expect(find.text('PROTOKOLL'), findsOneWidget);
    expect(find.text('2 Einträge'), findsOneWidget);
    expect(find.text('Erster Lagebericht'), findsNothing);

    // Tap auf die Kopfzeile klappt auf …
    await tester.tap(find.text('PROTOKOLL'));
    await tester.pumpAndSettle();
    expect(find.text('Erster Lagebericht'), findsOneWidget);
    expect(find.text('Zweiter Lagebericht'), findsOneWidget);

    // … und wieder zu.
    await tester.tap(find.text('PROTOKOLL'));
    await tester.pumpAndSettle();
    expect(find.text('Erster Lagebericht'), findsNothing);
  });

  testWidgets('Ohne collapsible bleibt die Chronik immer offen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: ListView(
            children: const [
              LogPanel(entries: entries, lang: AppLang.de, embedded: true),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Erster Lagebericht'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });
}
