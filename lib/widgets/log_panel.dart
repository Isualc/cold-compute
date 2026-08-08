import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../theme.dart';
import 'visual_shell.dart';

class LogPanel extends StatelessWidget {
  final List<LogEntry> entries;
  final AppLang lang;
  final EdgeInsetsGeometry padding;

  /// Ohne eigenen Scroller rendern (mobile Gesamtansicht).
  final bool embedded;

  /// Höchstens so viele (neueste) Einträge zeigen. Null = alle.
  final int? limit;

  /// Kopfzeile als Auf-/Zuklapp-Schalter rendern. Der Zustand liegt beim
  /// Eltern-Widget, weil sich am Desktop die Spaltenaufteilung mitändert.
  final bool collapsible;
  final bool collapsed;
  final VoidCallback? onToggle;

  const LogPanel({
    super.key,
    required this.entries,
    required this.lang,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 28),
    this.embedded = false,
    this.limit,
    this.collapsible = false,
    this.collapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final all = entries.reversed.toList();
    final reversed = limit == null ? all : all.take(limit!).toList();
    final showBody = !(collapsible && collapsed);

    Widget header = Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, showBody ? 8 : 14),
      child: SectionLabel(
        Strings(lang).protocol,
        color: AppTheme.amber,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusPill(
              label:
                  '${entries.length} ${lang == AppLang.de ? 'Einträge' : 'entries'}',
              color: AppTheme.textSecondary,
              icon: Icons.history,
            ),
            if (collapsible) ...[
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: collapsed ? -.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (collapsible) {
      header = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          child: header,
        ),
      );
    }

    if (!showBody) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header],
      );
    }

    return Column(
      mainAxisSize: embedded ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        if (reversed.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Text(
              lang == AppLang.de
                  ? 'Noch keine Lageeinträge.'
                  : 'No situation entries yet.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else if (embedded)
          Padding(
            padding: padding,
            child: Column(
              children: [
                for (var index = 0; index < reversed.length; index++)
                  _TimelineEntry(
                    entry: reversed[index],
                    lang: lang,
                    isLast: index == reversed.length - 1,
                  ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              key: const PageStorageKey('chronicle'),
              padding: padding,
              itemCount: reversed.length,
              itemBuilder: (context, index) => _TimelineEntry(
                entry: reversed[index],
                lang: lang,
                isLast: index == reversed.length - 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final LogEntry entry;
  final AppLang lang;
  final bool isLast;

  const _TimelineEntry({
    required this.entry,
    required this.lang,
    required this.isLast,
  });

  Color get _color => switch (entry.kind) {
    LogKind.decision => AppTheme.blue,
    LogKind.outcome => AppTheme.amber,
    LogKind.ending => AppTheme.danger,
    LogKind.worldTick => AppTheme.tealBright,
    LogKind.narration => AppTheme.textSecondary,
  };

  IconData get _icon => switch (entry.kind) {
    LogKind.decision => Icons.call_split_rounded,
    LogKind.outcome => Icons.casino_outlined,
    LogKind.ending => Icons.flag_outlined,
    LogKind.worldTick => Icons.public,
    LogKind.narration => Icons.fiber_manual_record,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: .1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color.withValues(alpha: .5)),
                  ),
                  child: Icon(_icon, color: _color, size: 12),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: AppTheme.lineSoft),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: GlassPanel(
                padding: const EdgeInsets.all(13),
                blur: false,
                borderColor: _color.withValues(alpha: .16),
                tint: AppTheme.surface.withValues(alpha: .65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.label.toUpperCase(),
                          style: TextStyle(
                            color: _color,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        const Spacer(),
                        if (entry.dieRoll != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.amber.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.amber.withValues(alpha: .28),
                              ),
                            ),
                            child: Text(
                              '${Strings(lang).die} · ${entry.dieRoll}',
                              style: const TextStyle(
                                color: AppTheme.amber,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
