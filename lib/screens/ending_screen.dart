import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../models/ending.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../providers/game_provider.dart';
import '../theme.dart';
import '../widgets/visual_shell.dart';
import '../widgets/world_map.dart';
import '../widgets/world_metrics.dart';

class EndingView extends StatelessWidget {
  final Ending? ending;
  final GameState state;

  const EndingView({super.key, required this.ending, required this.state});

  Color get _toneColor => switch (ending?.tone) {
    EndingTone.triumph => AppTheme.green,
    EndingTone.mixed => AppTheme.amber,
    EndingTone.defeat || null => AppTheme.danger,
  };

  IconData get _toneIcon => switch (ending?.tone) {
    EndingTone.triumph => Icons.flare_rounded,
    EndingTone.mixed => Icons.balance_outlined,
    EndingTone.defeat || null => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final lang = state.lang;
    final strings = Strings(lang);
    final provider = context.read<GameProvider>();
    final de = lang == AppLang.de;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                StatusPill(
                  label: '${strings.gameOver} · ${state.turnLabel}',
                  color: _toneColor,
                  icon: _toneIcon,
                  pulse: true,
                ),
                const SizedBox(height: 18),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _toneColor.withValues(alpha: .1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _toneColor.withValues(alpha: .55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _toneColor.withValues(alpha: .23),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Icon(_toneIcon, color: _toneColor, size: 32),
                ),
                const SizedBox(height: 18),
                Text(
                  ending?.title.t(lang) ?? '—',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: _toneColor,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Text(
                    ending?.description.t(lang) ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (ending?.source != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    ending!.source!.t(lang),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textFaint,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                WorldSituationMap(state: state, height: 230, showBrief: false),
                const SizedBox(height: 12),
                GlassPanel(
                  padding: const EdgeInsets.all(15),
                  blur: false,
                  child: EraTimelineRail(state: state),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SectionLabel(
                    de ? 'Finaler Systemzustand' : 'Final system state',
                    color: _toneColor,
                  ),
                ),
                const SizedBox(height: 9),
                MetricDashboard(state: state),
                const SizedBox(height: 18),
                GlassPanel(
                  padding: const EdgeInsets.all(15),
                  blur: false,
                  borderColor: _toneColor.withValues(alpha: .2),
                  child: Row(
                    children: [
                      _DossierFact(
                        label: de ? 'ENTSCHEIDUNGEN' : 'DECISIONS',
                        value: state.log
                            .where((entry) => entry.kind == LogKind.decision)
                            .length
                            .toString()
                            .padLeft(2, '0'),
                        color: _toneColor,
                      ),
                      const _DossierDivider(),
                      _DossierFact(
                        label: de ? 'EREIGNISSE' : 'EVENTS',
                        value: state.firedEvents.length.toString().padLeft(
                          2,
                          '0',
                        ),
                        color: _toneColor,
                      ),
                      const _DossierDivider(),
                      _DossierFact(
                        label: 'SEED',
                        value: state.seed
                            .toRadixString(16)
                            .toUpperCase()
                            .padLeft(8, '0')
                            .substring(0, 8),
                        color: _toneColor,
                        small: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await provider.abandonGame();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: Text(strings.backToStart),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DossierFact extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _DossierFact({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: color,
              fontSize: small ? 13 : 22,
              fontWeight: FontWeight.w900,
              letterSpacing: small ? .3 : -.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textFaint,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _DossierDivider extends StatelessWidget {
  const _DossierDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppTheme.lineSoft);
  }
}
