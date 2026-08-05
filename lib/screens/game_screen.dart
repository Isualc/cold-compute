import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/scenario.dart';
import '../l10n/strings.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../providers/game_provider.dart';
import '../services/game_feedback.dart';
import '../theme.dart';
import '../widgets/event_card.dart';
import '../widgets/log_panel.dart';
import '../widgets/ops_panel.dart';
import '../widgets/visual_shell.dart';
import '../widgets/world_map.dart';
import '../widgets/world_metrics.dart';
import 'codex_screen.dart';
import 'ending_screen.dart';

class GameScreen extends StatefulWidget {
  final bool showOpening;

  const GameScreen({super.key, this.showOpening = true});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _advancing = false;
  bool _showSequence = false;
  String _sequenceEyebrow = '';
  String _sequenceTitle = '';
  String _sequenceDetail = '';

  @override
  void initState() {
    super.initState();
    _showSequence = widget.showOpening;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    if (state == null) {
      return const Scaffold(
        body: StrategicBackdrop(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.showOpening && _sequenceTitle.isEmpty) {
      final de = state.lang == AppLang.de;
      _sequenceEyebrow = de ? 'MISSION BEGINNT' : 'MISSION START';
      _sequenceTitle = state.turnLabel;
      _sequenceDetail = de
          ? 'Das globale KI-Rennen wird zur Staatsfrage.'
          : 'The global AI race becomes a matter of state.';
    }

    return PopScope(
      canPop: !_advancing,
      child: Scaffold(
        body: StrategicBackdrop(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    _SituationHeader(
                      state: state,
                      onMenu: () => _openMenu(context, provider, state),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 1080) {
                            return _DesktopCommandCenter(
                              provider: provider,
                              onNextTurn: _advanceTurn,
                              advancing: _advancing,
                            );
                          }
                          return _MobileCommandCenter(
                            provider: provider,
                            onNextTurn: _advanceTurn,
                            advancing: _advancing,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (_showSequence)
                  Positioned.fill(
                    child: _SequenceOverlay(
                      eyebrow: _sequenceEyebrow,
                      title: _sequenceTitle,
                      detail: _sequenceDetail,
                      state: state,
                      soundEnabled: provider.soundEnabled,
                      onComplete: () {
                        if (mounted) setState(() => _showSequence = false);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _advanceTurn() async {
    if (_advancing) return;
    final provider = context.read<GameProvider>();
    final before = provider.state;
    if (before == null || before.isOver) return;

    setState(() {
      _advancing = true;
      _showSequence = true;
      _sequenceEyebrow = before.lang == AppLang.de
          ? 'ZEITSPRUNG · WELTLAGE WIRD BERECHNET'
          : 'TIME SHIFT · RESOLVING WORLD STATE';
      _sequenceTitle = _nextTurnLabel(before);
      _sequenceDetail = before.lang == AppLang.de
          ? 'Compute, Diplomatie und Schattenprojekte bewegen sich weiter.'
          : 'Compute, diplomacy and covert projects keep moving.';
    });

    await provider.nextTurn();
    if (!mounted) return;
    final reduced = MediaQuery.of(context).disableAnimations;
    if (!reduced) await Future<void>.delayed(const Duration(milliseconds: 620));
    if (!mounted) return;
    setState(() {
      _advancing = false;
      _showSequence = false;
    });
  }

  String _nextTurnLabel(GameState state) {
    final next = state.turn + 1;
    final year = GameState.startYear + ((next + 1) ~/ 2);
    final half = next.isEven ? 'H2' : 'H1';
    return '$half $year';
  }

  Future<void> _openMenu(
    BuildContext context,
    GameProvider provider,
    GameState state,
  ) async {
    final de = state.lang == AppLang.de;
    GameFeedback.navigate(enabled: provider.soundEnabled);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassPanel(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.line,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SectionLabel(de ? 'Operationsmenü' : 'Operations menu'),
                const SizedBox(height: 10),
                Consumer<GameProvider>(
                  builder: (context, liveProvider, _) => SwitchListTile(
                    secondary: Icon(
                      liveProvider.soundEnabled
                          ? Icons.volume_up_outlined
                          : Icons.volume_off_outlined,
                      color: AppTheme.tealBright,
                    ),
                    title: Text(de ? 'Sound & Haptik' : 'Sound & haptics'),
                    subtitle: Text(
                      de
                          ? 'Cues für Scans, Auswahl und W20.'
                          : 'Cues for scans, choices and the D20.',
                    ),
                    value: liveProvider.soundEnabled,
                    activeThumbColor: AppTheme.tealBright,
                    onChanged: (enabled) {
                      liveProvider.setSoundEnabled(enabled);
                      GameFeedback.toggle(enabled: enabled);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.menu_book_outlined,
                    color: AppTheme.tealBright,
                  ),
                  title: Text(de ? 'Codex & Quellen' : 'Codex & sources'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    GameFeedback.navigate(enabled: provider.soundEnabled);
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CodexScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  title: Text(de ? 'Zum Startbildschirm' : 'Return to start'),
                  subtitle: Text(
                    de
                        ? 'Der aktuelle Spielstand bleibt gespeichert.'
                        : 'Your current game remains saved.',
                  ),
                  onTap: () {
                    GameFeedback.navigate(enabled: provider.soundEnabled);
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.danger,
                  ),
                  title: Text(
                    de ? 'Partie aufgeben' : 'Abandon game',
                    style: const TextStyle(color: AppTheme.danger),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await provider.abandonGame();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SituationHeader extends StatelessWidget {
  final GameState state;
  final VoidCallback onMenu;

  const _SituationHeader({required this.state, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final phaseColor = _phaseColor(state.treatyPhase);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.tealBright.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.tealBright.withValues(alpha: .27),
              ),
            ),
            child: const Icon(
              Icons.blur_on,
              color: AppTheme.tealBright,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COLD COMPUTE',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                ),
              ),
              Text(
                state.turnLabel,
                style: const TextStyle(
                  color: AppTheme.amber,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusPill(
                label: state.treatyPhase.label(state.lang),
                color: phaseColor,
                pulse: true,
              ),
            ),
          ),
          const SizedBox(width: 5),
          SignalButton(
            icon: Icons.more_horiz,
            tooltip: state.lang == AppLang.de ? 'Menü' : 'Menu',
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _MobileCommandCenter extends StatelessWidget {
  final GameProvider provider;
  final VoidCallback onNextTurn;
  final bool advancing;

  const _MobileCommandCenter({
    required this.provider,
    required this.onNextTurn,
    required this.advancing,
  });

  /// Mobil zeigt dieselbe Lage wie am Desktop, nur untereinander:
  /// Zeitleiste, Weltkarte, Metriken, Briefing, Operationen, Chronik.
  @override
  Widget build(BuildContext context) {
    final state = provider.state!;
    final strings = Strings(state.lang);
    final de = state.lang == AppLang.de;

    if (state.isOver) {
      return EndingView(ending: Scenario.endings[state.endingId], state: state);
    }

    return ListView(
      key: const PageStorageKey('mobile_command_center'),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
      children: [
        GlassPanel(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          blur: false,
          child: EraTimelineRail(state: state),
        ),
        const SizedBox(height: 10),
        WorldSituationMap(state: state, height: 210),
        const SizedBox(height: 12),
        SectionLabel(strings.worldState, color: AppTheme.textSecondary),
        const SizedBox(height: 8),
        MetricDashboard(state: state),
        const SizedBox(height: 12),
        _LatestSignal(state: state),
        const SizedBox(height: 16),
        SectionLabel(
          provider.currentDecision != null
              ? strings.decision
              : (de ? 'Briefing' : 'Briefing'),
          color: provider.currentDecision != null
              ? AppTheme.danger
              : AppTheme.tealBright,
        ),
        const SizedBox(height: 8),
        _MobileBriefing(
          provider: provider,
          onNextTurn: onNextTurn,
          advancing: advancing,
        ),
        const SizedBox(height: 18),
        ...OpsPanel(provider: provider).buildSections(context),
        const SizedBox(height: 6),
        GlassPanel(
          padding: EdgeInsets.zero,
          blur: false,
          child: LogPanel(
            entries: state.log,
            lang: state.lang,
            embedded: true,
            limit: 12,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          ),
        ),
      ],
    );
  }
}

/// Briefing-Bereich der mobilen Gesamtansicht: Entscheidungskarte,
/// Würfelergebnis oder Rundenabschluss — jeweils ohne eigenen Scroller.
class _MobileBriefing extends StatelessWidget {
  final GameProvider provider;
  final VoidCallback onNextTurn;
  final bool advancing;

  const _MobileBriefing({
    required this.provider,
    required this.onNextTurn,
    required this.advancing,
  });

  @override
  Widget build(BuildContext context) {
    final state = provider.state!;
    final strings = Strings(state.lang);
    final decision = provider.currentDecision;
    final outcome = provider.lastOutcome;

    if (decision != null && outcome != null) {
      return OutcomeView(
        outcome: outcome,
        dieRoll: _lastRoll(state),
        lang: state.lang,
        soundEnabled: provider.soundEnabled,
        embedded: true,
        onContinue: () {
          GameFeedback.navigate(enabled: provider.soundEnabled);
          provider.acknowledgeOutcome();
        },
      );
    }
    if (decision != null) {
      return EventCardView(
        event: decision,
        state: state,
        embedded: true,
        onChoose: (choice) {
          GameFeedback.decision(enabled: provider.soundEnabled);
          provider.choose(choice);
        },
      );
    }

    // Runde abgeschlossen: Weiter zum nächsten Halbjahr.
    return Column(
      children: [
        Text(
          state.lang == AppLang.de
              ? 'Alle Entscheidungen dieses Halbjahres sind getroffen.'
              : 'Every decision for this half-year has been made.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            key: const ValueKey('next_turn_button'),
            onPressed: advancing ? null : onNextTurn,
            icon: advancing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.fast_forward_rounded),
            label: Text(strings.nextHalfYear),
          ),
        ),
      ],
    );
  }

  int? _lastRoll(GameState state) {
    for (final entry in state.log.reversed) {
      if (entry.dieRoll != null) return entry.dieRoll;
    }
    return null;
  }
}

class _DesktopCommandCenter extends StatelessWidget {
  final GameProvider provider;
  final VoidCallback onNextTurn;
  final bool advancing;

  const _DesktopCommandCenter({
    required this.provider,
    required this.onNextTurn,
    required this.advancing,
  });

  @override
  Widget build(BuildContext context) {
    final state = provider.state!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 360,
            child: _WorldOverview(
              state: state,
              onNextTurn: onNextTurn,
              advancing: advancing,
              dense: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ColoredBox(
                color: AppTheme.bg.withValues(alpha: .3),
                child: _MainPanel(
                  provider: provider,
                  onNextTurn: onNextTurn,
                  advancing: advancing,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 350,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    blur: false,
                    child: OpsPanel(
                      provider: provider,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 4,
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    blur: false,
                    child: LogPanel(entries: state.log, lang: state.lang),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldOverview extends StatelessWidget {
  final GameState state;
  final VoidCallback onNextTurn;
  final bool advancing;
  final bool dense;

  const _WorldOverview({
    required this.state,
    required this.onNextTurn,
    required this.advancing,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = Strings(state.lang);
    return ListView(
      key: const PageStorageKey('world_overview'),
      padding: EdgeInsets.fromLTRB(
        dense ? 0 : 14,
        7,
        dense ? 0 : 14,
        dense ? 28 : 108,
      ),
      children: [
        GlassPanel(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          blur: false,
          child: EraTimelineRail(state: state),
        ),
        const SizedBox(height: 10),
        WorldSituationMap(
          state: state,
          height: dense ? 195 : 218,
          showBrief: !dense,
        ),
        const SizedBox(height: 10),
        SectionLabel(strings.worldState, color: AppTheme.textSecondary),
        const SizedBox(height: 8),
        MetricDashboard(state: state, compact: dense),
        const SizedBox(height: 12),
        _LatestSignal(state: state),
        if (!state.isOver) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const ValueKey('next_turn_overview'),
              onPressed: advancing ? null : onNextTurn,
              icon: advancing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.fast_forward_rounded),
              label: Text(strings.nextHalfYear),
            ),
          ),
        ],
      ],
    );
  }
}

class _MainPanel extends StatelessWidget {
  final GameProvider provider;
  final VoidCallback onNextTurn;
  final bool advancing;

  const _MainPanel({
    required this.provider,
    required this.onNextTurn,
    required this.advancing,
  });

  @override
  Widget build(BuildContext context) {
    final state = provider.state!;
    if (state.isOver) {
      return EndingView(ending: Scenario.endings[state.endingId], state: state);
    }

    final decision = provider.currentDecision;
    final outcome = provider.lastOutcome;
    final key = outcome != null
        ? 'outcome_${state.turn}_${decision?.id}'
        : decision != null
        ? 'decision_${decision.id}'
        : 'recap_${state.turn}';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(.025, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(key),
        child: switch ((decision, outcome)) {
          (_, final result?) => OutcomeView(
            outcome: result,
            dieRoll: _lastRoll(state),
            lang: state.lang,
            soundEnabled: provider.soundEnabled,
            onContinue: () {
              GameFeedback.navigate(enabled: provider.soundEnabled);
              provider.acknowledgeOutcome();
            },
          ),
          (final event?, null) => EventCardView(
            event: event,
            state: state,
            onChoose: (choice) {
              GameFeedback.decision(enabled: provider.soundEnabled);
              provider.choose(choice);
            },
          ),
          _ => _TurnRecap(
            state: state,
            onNextTurn: onNextTurn,
            advancing: advancing,
          ),
        },
      ),
    );
  }

  int? _lastRoll(GameState state) {
    for (final entry in state.log.reversed) {
      if (entry.dieRoll != null) return entry.dieRoll;
    }
    return null;
  }
}

class _TurnRecap extends StatelessWidget {
  final GameState state;
  final VoidCallback onNextTurn;
  final bool advancing;

  const _TurnRecap({
    required this.state,
    required this.onNextTurn,
    required this.advancing,
  });

  @override
  Widget build(BuildContext context) {
    final strings = Strings(state.lang);
    final de = state.lang == AppLang.de;
    final turnEntries = state.log
        .where(
          (entry) =>
              entry.turn == state.turn && entry.kind == LogKind.narration,
        )
        .toList();
    final latestWorld = state.log.reversed
        .where((entry) => entry.kind == LogKind.worldTick)
        .cast<LogEntry?>()
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 108),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  label: de
                      ? 'Lagezyklus abgeschlossen'
                      : 'Situation cycle complete',
                  color: AppTheme.tealBright,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                Text(
                  state.turnLabel,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  latestWorld?.text ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (turnEntries.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SectionLabel(
                    de
                        ? 'Eingegangene Lageberichte'
                        : 'Incoming situation reports',
                    color: AppTheme.amber,
                  ),
                  const SizedBox(height: 9),
                  ...turnEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(15),
                        blur: false,
                        borderColor: AppTheme.amber.withValues(alpha: .18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.amber.withValues(alpha: .09),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.satellite_alt_outlined,
                                color: AppTheme.amber,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    entry.text,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                GlassPanel(
                  padding: const EdgeInsets.all(15),
                  blur: false,
                  child: EraTimelineRail(state: state),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const ValueKey('next_turn_button'),
                    onPressed: advancing ? null : onNextTurn,
                    icon: advancing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fast_forward_rounded),
                    label: Text(strings.nextHalfYear),
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

class _LatestSignal extends StatelessWidget {
  final GameState state;

  const _LatestSignal({required this.state});

  @override
  Widget build(BuildContext context) {
    final latest = state.log.isEmpty ? null : state.log.last;
    if (latest == null) return const SizedBox.shrink();
    return GlassPanel(
      padding: const EdgeInsets.all(13),
      blur: false,
      borderColor: AppTheme.amber.withValues(alpha: .16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sensors, color: AppTheme.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latest.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  latest.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SequenceOverlay extends StatefulWidget {
  final String eyebrow;
  final String title;
  final String detail;
  final GameState state;
  final bool soundEnabled;
  final VoidCallback onComplete;

  const _SequenceOverlay({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.state,
    required this.soundEnabled,
    required this.onComplete,
  });

  @override
  State<_SequenceOverlay> createState() => _SequenceOverlayState();
}

class _SequenceOverlayState extends State<_SequenceOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1250),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onComplete();
          })
          ..forward();
    GameFeedback.scan(enabled: widget.soundEnabled);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations && !_controller.isCompleted) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor(widget.state.treatyPhase);
    return Material(
      color: AppTheme.bg,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final entrance = Curves.easeOutCubic.transform(
            (_controller.value / .55).clamp(0, 1),
          );
          final exit = _controller.value < .78
              ? 1.0
              : 1.0 - ((_controller.value - .78) / .22).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _SequencePainter(
                  progress: _controller.value,
                  color: color,
                ),
              ),
              Opacity(
                opacity: exit,
                child: Transform.translate(
                  offset: Offset(0, (1 - entrance) * 22),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.eyebrow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: color,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 56,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 11),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Text(
                              widget.detail,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(
                              value: _controller.value,
                              minHeight: 2,
                              color: color,
                              backgroundColor: AppTheme.line,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SequencePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SequencePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: .065)
      ..strokeWidth = .7;
    const spacing = 42.0;
    for (
      double x = -spacing + progress * spacing;
      x < size.width;
      x += spacing
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final scanY = progress * size.height;
    final scan = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withValues(alpha: .18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 35, size.width, 70));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 35, size.width, 70), scan);
  }

  @override
  bool shouldRepaint(covariant _SequencePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

Color _phaseColor(TreatyPhase phase) => switch (phase) {
  TreatyPhase.none || TreatyPhase.collapsed => AppTheme.danger,
  TreatyPhase.negotiation => AppTheme.amber,
  TreatyPhase.moratorium => AppTheme.covert,
  TreatyPhase.controlledAscent => AppTheme.green,
  _ => AppTheme.tealBright,
};
