import 'package:flutter/material.dart';

import '../models/lang.dart';
import '../models/metrics.dart';
import '../theme.dart';

class MetricBar extends StatelessWidget {
  final Metric metric;
  final double value;
  final AppLang lang;
  final bool dense;
  final bool showLabel;

  const MetricBar({
    super.key,
    required this.metric,
    required this.value,
    required this.lang,
    this.dense = false,
    this.showLabel = true,
  });

  bool get _inverted =>
      metric == Metric.covertRisk || metric == Metric.escalation;
  Color get _color => AppTheme.valueColor(value, inverted: _inverted);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${metric.label(lang)} ${value.round()} von 100',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 4 : 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      metric.label(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: dense ? 10.5 : 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: value),
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    builder: (context, animated, _) => Text(
                      animated.round().toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: _color,
                        fontSize: dense ? 10.5 : 12,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: dense ? 3 : 5),
            ],
            Container(
              height: dense ? 4 : 6,
              decoration: BoxDecoration(
                color: AppTheme.surfaceHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              clipBehavior: Clip.antiAlias,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: value / 100),
                duration: const Duration(milliseconds: 680),
                curve: Curves.easeOutCubic,
                builder: (context, animated, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: animated.clamp(0, 1),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_color.withValues(alpha: .62), _color],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: _color, blurRadius: 6)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
