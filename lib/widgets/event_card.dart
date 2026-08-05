import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';
import '../services/game_feedback.dart';
import '../theme.dart';
import 'visual_shell.dart';

class EventCardView extends StatelessWidget {
  final GameEvent event;
  final GameState state;
  final void Function(EventChoice choice) onChoose;

  /// In eine bestehende Liste eingebettet: kein eigener Scroller, damit die
  /// mobile Lageübersicht alles in einem Fluss zeigen kann.
  final bool embedded;

  const EventCardView({
    super.key,
    required this.event,
    required this.state,
    required this.onChoose,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.lang;
    final strings = Strings(lang);
    final presentation = _EventPresentation.forEvent(event);

    final content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusPill(
                    label: '${strings.decision} · ${state.turnLabel}',
                    color: presentation.color,
                    icon: presentation.icon,
                    pulse: true,
                  ),
                  const Spacer(),
                  Text(
                    'SIGNAL // ${event.id.hashCode.abs().toString().padLeft(5, '0').substring(0, 5)}',
                    style: const TextStyle(
                      color: AppTheme.textFaint,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlassPanel(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(22),
                borderColor: presentation.color.withValues(alpha: .28),
                blur: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            presentation.color,
                            presentation.color.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                            presentation.label(lang),
                            color: presentation.color,
                          ),
                          const SizedBox(height: 13),
                          Text(
                            event.title.t(lang),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 13),
                          Text(
                            event.description.t(lang),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15.5,
                                ),
                          ),
                          if (event.source != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.bg.withValues(alpha: .48),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: AppTheme.lineSoft),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.auto_stories_outlined,
                                    size: 14,
                                    color: AppTheme.textFaint,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.source!.t(lang),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 10.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionLabel(
                lang == AppLang.de
                    ? 'Dein Mandat · ${event.choicesFor(state).length} Optionen'
                    : 'Your mandate · ${event.choicesFor(state).length} options',
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 10),
              ...event.choicesFor(state).indexed.map(
                (entry) => _ChoiceCard(
                  index: entry.$1,
                  choice: entry.$2,
                  state: state,
                  accent: presentation.color,
                  onChoose: onChoose,
                ),
              ),
            ],
          ),
        ),
    );

    if (embedded) return content;
    return SingleChildScrollView(
      key: ValueKey('event_${event.id}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 108),
      child: content,
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final int index;
  final EventChoice choice;
  final GameState state;
  final Color accent;
  final void Function(EventChoice choice) onChoose;

  const _ChoiceCard({
    required this.index,
    required this.choice,
    required this.state,
    required this.accent,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = choice.enabledIf?.call(state) ?? true;
    final lang = state.lang;
    final signals = _signals(choice);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('choice_$index'),
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? () => onChoose(choice) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.surface.withValues(alpha: .88)
                  : AppTheme.surface.withValues(alpha: .42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled
                    ? accent.withValues(alpha: .27)
                    : AppTheme.lineSoft,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (enabled ? accent : AppTheme.textFaint).withValues(
                      alpha: .1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (enabled ? accent : AppTheme.textFaint).withValues(
                        alpha: .32,
                      ),
                    ),
                  ),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: TextStyle(
                      color: enabled ? accent : AppTheme.textFaint,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.label.t(lang),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: enabled
                                  ? AppTheme.textPrimary
                                  : AppTheme.textFaint,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enabled
                            ? choice.description.t(lang)
                            : (choice.lockedHint?.t(lang) ??
                                  choice.description.t(lang)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: enabled
                              ? AppTheme.textSecondary
                              : AppTheme.textFaint,
                        ),
                      ),
                      if (signals.isNotEmpty && enabled) ...[
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: signals
                              .take(3)
                              .map(
                                (signal) =>
                                    _SignalChip(signal: signal, lang: lang),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  enabled ? Icons.arrow_forward_rounded : Icons.lock_outline,
                  color: enabled ? accent : AppTheme.textFaint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_ChoiceSignal> _signals(EventChoice choice) {
    final values = <Metric, List<double>>{};
    for (final outcome in choice.outcomes) {
      for (final entry in outcome.effect.deltas.entries) {
        values.putIfAbsent(entry.key, () => []).add(entry.value);
      }
    }
    return values.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return _ChoiceSignal(entry.key, average);
    }).toList();
  }
}

class _ChoiceSignal {
  final Metric metric;
  final double direction;

  const _ChoiceSignal(this.metric, this.direction);
}

class _SignalChip extends StatelessWidget {
  final _ChoiceSignal signal;
  final AppLang lang;

  const _SignalChip({required this.signal, required this.lang});

  @override
  Widget build(BuildContext context) {
    final dangerMetric = signal.metric == Metric.covertRisk;
    final positive = dangerMetric ? signal.direction < 0 : signal.direction > 0;
    final color = positive ? AppTheme.green : AppTheme.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(
        '${signal.metric.label(lang)} ${signal.direction >= 0 ? '↑' : '↓'}',
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class OutcomeView extends StatefulWidget {
  final Outcome outcome;
  final int? dieRoll;
  final AppLang lang;
  final bool soundEnabled;
  final VoidCallback onContinue;

  /// Ohne eigenen Scroller rendern (mobile Gesamtansicht).
  final bool embedded;

  const OutcomeView({
    super.key,
    required this.outcome,
    required this.dieRoll,
    required this.lang,
    this.soundEnabled = true,
    required this.onContinue,
    this.embedded = false,
  });

  @override
  State<OutcomeView> createState() => _OutcomeViewState();
}

class _OutcomeViewState extends State<OutcomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _playedResolutionCue = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1050),
          )
          ..addListener(() {
            if (!_playedResolutionCue && _controller.value >= .72) {
              _playedResolutionCue = true;
              GameFeedback.outcome(
                enabled: widget.soundEnabled,
                critical: _outcomeTone(widget.outcome) == AppTheme.danger,
              );
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(widget.lang);
    final roll = widget.dieRoll;
    final tone = _outcomeTone(widget.outcome);

    final content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = Curves.easeOutCubic.transform(_controller.value);
              final visible = ((_controller.value - .55) / .45).clamp(0.0, 1.0);
              final displayRoll = roll == null
                  ? null
                  : (_controller.value < .72
                        ? ((math.sin(_controller.value * 90).abs() * 19)
                                  .floor() +
                              1)
                        : roll);
              return Column(
                children: [
                  SectionLabel(
                    widget.lang == AppLang.de
                        ? 'Konsequenz wird berechnet'
                        : 'Resolving consequence',
                    color: tone,
                  ),
                  const SizedBox(height: 18),
                  if (displayRoll != null) ...[
                    Transform.rotate(
                      angle: (1 - value) * math.pi * 3,
                      child: Container(
                        width: 94,
                        height: 94,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(color: tone, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: tone.withValues(alpha: .28),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          '$displayRoll',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: tone, fontSize: 38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      strings.die,
                      style: const TextStyle(
                        color: AppTheme.textFaint,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 19),
                  ],
                  Opacity(
                    opacity: visible,
                    child: Transform.translate(
                      offset: Offset(0, (1 - visible) * 14),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(20),
                        blur: false,
                        borderColor: tone.withValues(alpha: .28),
                        child: Column(
                          children: [
                            Icon(_toneIcon(tone), color: tone, size: 24),
                            const SizedBox(height: 12),
                            Text(
                              widget.outcome.text.t(widget.lang),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (widget.outcome.effect.deltas.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 7,
                                runSpacing: 7,
                                children: widget.outcome.effect.deltas.entries
                                    .map(
                                      (entry) => _DeltaChip(
                                        metric: entry.key,
                                        delta: entry.value,
                                        lang: widget.lang,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: visible > .95
                                    ? widget.onContinue
                                    : null,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(strings.next),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

    if (widget.embedded) return content;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
      child: content,
    );
  }

  Color _outcomeTone(Outcome outcome) {
    if (outcome.endingId != null) return AppTheme.danger;
    var score = 0.0;
    for (final entry in outcome.effect.deltas.entries) {
      score += entry.key == Metric.covertRisk ? -entry.value : entry.value;
    }
    if (score > 2) return AppTheme.green;
    if (score < -2) return AppTheme.danger;
    return AppTheme.amber;
  }

  IconData _toneIcon(Color tone) {
    if (tone == AppTheme.green) return Icons.check_circle_outline;
    if (tone == AppTheme.danger) return Icons.warning_amber_rounded;
    return Icons.change_circle_outlined;
  }
}

class _DeltaChip extends StatelessWidget {
  final Metric metric;
  final double delta;
  final AppLang lang;

  const _DeltaChip({
    required this.metric,
    required this.delta,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final positive = metric == Metric.covertRisk ? delta < 0 : delta > 0;
    final color = positive ? AppTheme.green : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(
        '${metric.label(lang)} ${delta >= 0 ? '+' : ''}${delta.round()}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EventPresentation {
  final Color color;
  final IconData icon;
  final String type;

  const _EventPresentation(this.color, this.icon, this.type);

  factory _EventPresentation.forEvent(GameEvent event) {
    final id = event.id.toLowerCase();
    if (id.contains('cyber') || id.contains('covert') || id.contains('spy')) {
      return const _EventPresentation(
        AppTheme.covert,
        Icons.radar,
        'INTELLIGENCE',
      );
    }
    if (id.contains('deal') || id.contains('treaty') || id.contains('path')) {
      return const _EventPresentation(
        AppTheme.tealBright,
        Icons.handshake_outlined,
        'DIPLOMACY',
      );
    }
    if (id.contains('election') || id.contains('congress')) {
      return const _EventPresentation(
        AppTheme.amber,
        Icons.account_balance_outlined,
        'POLITICS',
      );
    }
    if (id.contains('war') || id.contains('sabotage')) {
      return const _EventPresentation(
        AppTheme.danger,
        Icons.warning_amber_rounded,
        'CRISIS',
      );
    }
    return const _EventPresentation(
      AppTheme.blue,
      Icons.crisis_alert_outlined,
      'STRATEGIC BRIEF',
    );
  }

  String label(AppLang lang) {
    if (lang == AppLang.en) return type;
    return switch (type) {
      'INTELLIGENCE' => 'NACHRICHTENLAGE',
      'DIPLOMACY' => 'DIPLOMATIE',
      'POLITICS' => 'INNENPOLITIK',
      'CRISIS' => 'KRISE',
      _ => 'STRATEGISCHES BRIEFING',
    };
  }
}
