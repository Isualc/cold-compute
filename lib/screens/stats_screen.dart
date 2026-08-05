import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/scenario.dart';
import '../l10n/strings.dart';
import '../models/ending.dart';
import '../models/game_record.dart';
import '../models/lang.dart';
import '../providers/game_provider.dart';
import '../theme.dart';
import '../widgets/visual_shell.dart';

/// Auswertung aller beendeten Partien: Kennzahlen, Enden-Verteilung, Historie.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final lang = provider.appLang;
    final de = lang == AppLang.de;
    final history = provider.history;

    return Scaffold(
      body: StrategicBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 14, 4),
                child: Row(
                  children: [
                    SignalButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings(lang).statsTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            de
                                ? 'PARTIEN · ENDEN · BILANZ'
                                : 'RUNS · ENDINGS · RECORD',
                            style: const TextStyle(
                              color: AppTheme.tealBright,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label:
                          '${history.length} ${de ? 'Partien' : 'runs'}',
                      color: AppTheme.textSecondary,
                      icon: Icons.insights_outlined,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: history.isEmpty
                        ? _EmptyState(de: de)
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                            children: [
                              _SummaryRow(history: history, de: de),
                              const SizedBox(height: 12),
                              _EndingDistribution(
                                history: history,
                                lang: lang,
                              ),
                              const SizedBox(height: 12),
                              _HistoryList(history: history, lang: lang),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  key: const ValueKey('clear_history_button'),
                                  onPressed: () =>
                                      _confirmClear(context, provider, de),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 17,
                                  ),
                                  label: Text(
                                    de
                                        ? 'Historie löschen'
                                        : 'Clear history',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.textFaint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    GameProvider provider,
    bool de,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(de ? 'Historie löschen?' : 'Clear history?'),
        content: Text(
          de
              ? 'Alle aufgezeichneten Partien werden entfernt. Das lässt '
                  'sich nicht rückgängig machen.'
              : 'All recorded runs will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              de ? 'Löschen' : 'Clear',
              style: const TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await provider.clearHistory();
  }
}

class _EmptyState extends StatelessWidget {
  final bool de;
  const _EmptyState({required this.de});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.query_stats_outlined,
              color: AppTheme.textFaint,
              size: 40,
            ),
            const SizedBox(height: 14),
            Text(
              de ? 'Noch keine beendete Partie.' : 'No finished runs yet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              de
                  ? 'Spiel eine Partie bis zu ihrem Ende — hier entsteht '
                      'dann deine Bilanz über alle Zeitlinien.'
                  : 'Play a run to its ending — your record across '
                      'timelines will build up here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<GameRecord> history;
  final bool de;
  const _SummaryRow({required this.history, required this.de});

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final lightcone =
        history.where((r) => r.endingId == 'plan_a_success').length;
    final quote = total == 0 ? 0 : (lightcone / total * 100).round();
    final defeats = history.where((r) {
      final tone = Scenario.endings[r.endingId]?.tone;
      return tone == EndingTone.defeat;
    }).length;

    // Meistgespielte Rolle.
    final roleCounts = <String, int>{};
    for (final r in history) {
      roleCounts[r.roleId] = (roleCounts[r.roleId] ?? 0) + 1;
    }
    final topRoleId = (roleCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .first
        .key;
    final topRole = Scenario.roles
        .firstWhere((role) => role.id == topRoleId,
            orElse: () => Scenario.roles.first)
        .name
        .t(de ? AppLang.de : AppLang.en);

    Widget chip(String value, String label, Color color) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.bg.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: .25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppTheme.textFaint,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        );

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      blur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            de ? 'Bilanz' : 'Record',
            color: AppTheme.tealBright,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              chip('$total', de ? 'PARTIEN' : 'RUNS', AppTheme.tealBright),
              const SizedBox(width: 8),
              chip(
                '$quote %',
                de ? 'LICHTKEGEL-QUOTE' : 'LIGHTCONE RATE',
                AppTheme.green,
              ),
              const SizedBox(width: 8),
              chip(
                '$defeats',
                de ? 'NIEDERLAGEN' : 'DEFEATS',
                AppTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            de ? 'Meistgespielte Rolle: $topRole' : 'Most played role: $topRole',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EndingDistribution extends StatelessWidget {
  final List<GameRecord> history;
  final AppLang lang;
  const _EndingDistribution({required this.history, required this.lang});

  @override
  Widget build(BuildContext context) {
    final de = lang == AppLang.de;
    final counts = <String, int>{};
    for (final r in history) {
      counts[r.endingId] = (counts[r.endingId] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.first.value;

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      blur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            de ? 'Enden-Verteilung' : 'Ending distribution',
            color: AppTheme.amber,
          ),
          const SizedBox(height: 10),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EndingBar(
                endingId: entry.key,
                count: entry.value,
                maxCount: maxCount,
                lang: lang,
              ),
            ),
        ],
      ),
    );
  }
}

class _EndingBar extends StatelessWidget {
  final String endingId;
  final int count;
  final int maxCount;
  final AppLang lang;

  const _EndingBar({
    required this.endingId,
    required this.count,
    required this.maxCount,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final ending = Scenario.endings[endingId];
    final color = switch (ending?.tone) {
      EndingTone.triumph => AppTheme.green,
      EndingTone.mixed => AppTheme.amber,
      EndingTone.defeat => AppTheme.danger,
      null => AppTheme.textFaint,
    };
    final title = ending?.title.t(lang) ?? endingId;

    return Row(
      children: [
        SizedBox(
          width: 168,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / maxCount,
              minHeight: 7,
              backgroundColor: AppTheme.bg.withValues(alpha: .6),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: .75)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<GameRecord> history;
  final AppLang lang;
  const _HistoryList({required this.history, required this.lang});

  String _formatDate(DateTime dt, bool de) {
    String two(int n) => n.toString().padLeft(2, '0');
    return de
        ? '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}'
        : '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final de = lang == AppLang.de;
    final shown = history.take(30).toList();

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      blur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            de
                ? 'Letzte Partien (${shown.length}/${history.length})'
                : 'Recent runs (${shown.length}/${history.length})',
            color: AppTheme.blue,
          ),
          const SizedBox(height: 10),
          for (final record in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryTile(
                record: record,
                lang: lang,
                date: _formatDate(record.endedAt, de),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final GameRecord record;
  final AppLang lang;
  final String date;

  const _HistoryTile({
    required this.record,
    required this.lang,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final ending = Scenario.endings[record.endingId];
    final color = switch (ending?.tone) {
      EndingTone.triumph => AppTheme.green,
      EndingTone.mixed => AppTheme.amber,
      EndingTone.defeat => AppTheme.danger,
      null => AppTheme.textFaint,
    };
    final role = Scenario.roles
        .firstWhere((r) => r.id == record.roleId,
            orElse: () => Scenario.roles.first)
        .name
        .t(lang);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.planPath,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ending?.title.t(lang) ?? record.endingId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date · $role',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textFaint,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            record.turnLabel,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
