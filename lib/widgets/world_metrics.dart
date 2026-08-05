import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';
import '../theme.dart';
import 'metric_bar.dart';
import 'visual_shell.dart';

class MetricDashboard extends StatelessWidget {
  final GameState state;
  final bool compact;

  const MetricDashboard({super.key, required this.state, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final de = state.lang == AppLang.de;
    final items = [
      _MetricClusterData(
        title: de ? 'Wettlauf' : 'AI race',
        icon: Icons.memory_outlined,
        accent: AppTheme.blue,
        metrics: const [Metric.usCapability, Metric.cnCapability],
      ),
      _MetricClusterData(
        title: de ? 'Sicherheit' : 'Safety',
        icon: Icons.shield_outlined,
        accent: AppTheme.tealBright,
        metrics: const [Metric.alignment, Metric.verification],
      ),
      _MetricClusterData(
        title: de ? 'Mandat' : 'Mandate',
        icon: Icons.account_balance_outlined,
        accent: AppTheme.amber,
        metrics: const [Metric.trust, Metric.politicalCapital],
      ),
      _MetricClusterData(
        title: de ? 'Druck & Schatten' : 'Pressure & shadow',
        icon: Icons.radar_outlined,
        accent: AppTheme.covert,
        metrics: const [Metric.publicPressure, Metric.covertRisk],
      ),
      _MetricClusterData(
        title: de ? 'Militärlage' : 'Military posture',
        icon: Icons.military_tech_outlined,
        accent: AppTheme.danger,
        metrics: const [Metric.escalation, Metric.intel],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 4 : 2;
        final spacing = compact ? 8.0 : 10.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: tileWidth,
                  child: _MetricCluster(state: state, data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricClusterData {
  final String title;
  final IconData icon;
  final Color accent;
  final List<Metric> metrics;

  const _MetricClusterData({
    required this.title,
    required this.icon,
    required this.accent,
    required this.metrics,
  });
}

class _MetricCluster extends StatelessWidget {
  final GameState state;
  final _MetricClusterData data;

  const _MetricCluster({required this.state, required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(11),
      blur: false,
      tint: AppTheme.surface.withValues(alpha: .72),
      borderColor: data.accent.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 14, color: data.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: data.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ...data.metrics.map(
            (metric) => MetricBar(
              metric: metric,
              value: state.metric(metric),
              lang: state.lang,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class EraTimelineRail extends StatelessWidget {
  final GameState state;

  const EraTimelineRail({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = ((state.year - 2026) / 14).clamp(0.0, 1.0);
    final color = switch (state.treatyPhase) {
      TreatyPhase.none || TreatyPhase.collapsed => AppTheme.danger,
      TreatyPhase.negotiation => AppTheme.amber,
      TreatyPhase.controlledAscent => AppTheme.green,
      TreatyPhase.moratorium => AppTheme.covert,
      _ => AppTheme.tealBright,
    };

    return Semantics(
      label: '${state.turnLabel}, ${state.treatyPhase.label(state.lang)}',
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '2026',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textFaint,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '2029  /  DEAL',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: state.year >= 2029
                      ? AppTheme.amber
                      : AppTheme.textFaint,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '2035  /  PAUSE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: state.year >= 2035
                      ? AppTheme.tealBright
                      : AppTheme.textFaint,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '2040',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textFaint,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) {
              final markerX = constraints.maxWidth * progress;
              return SizedBox(
                height: 15,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.line,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: color,
                          boxShadow: [BoxShadow(color: color, blurRadius: 6)],
                        ),
                      ),
                    ),
                    for (final position in const [3 / 14, 9 / 14])
                      Positioned(
                        left: constraints.maxWidth * position - 2,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.textFaint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Positioned(
                      left: (markerX - 6).clamp(0, constraints.maxWidth - 12),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          boxShadow: [BoxShadow(color: color, blurRadius: 9)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
