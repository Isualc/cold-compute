import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/scenario.dart';
import '../l10n/strings.dart';
import '../models/lang.dart';
import '../models/role.dart';
import '../providers/game_provider.dart';
import '../services/game_feedback.dart';
import '../theme.dart';
import '../widgets/visual_shell.dart';
import 'codex_screen.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  String _roleId = Scenario.roles.first.id;
  bool _launching = false;
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _newGame(BuildContext context) async {
    if (_launching) return;
    GameFeedback.launch(enabled: context.read<GameProvider>().soundEnabled);
    setState(() => _launching = true);
    final provider = context.read<GameProvider>();
    await provider.newGame(roleId: _roleId);
    if (!context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
    if (mounted) setState(() => _launching = false);
  }

  Future<void> _continueGame(BuildContext context) async {
    if (_launching) return;
    GameFeedback.navigate(enabled: context.read<GameProvider>().soundEnabled);
    setState(() => _launching = true);
    final provider = context.read<GameProvider>();
    final ok = await provider.continueGame();
    if (!ok || !context.mounted) {
      if (mounted) setState(() => _launching = false);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen(showOpening: false)),
    );
    if (mounted) setState(() => _launching = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final lang = provider.appLang;
    final strings = Strings(lang);
    final reduced = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: StrategicBackdrop(
        child: SafeArea(
          child: FadeTransition(
            opacity: reduced
                ? const AlwaysStoppedAnimation(1)
                : CurvedAnimation(parent: _intro, curve: Curves.easeOut),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 840;
                return Column(
                  children: [
                    _TopBar(provider: provider),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 48 : 20,
                            16,
                            wide ? 48 : 20,
                            28,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 11,
                                        child: _Hero(
                                          lang: lang,
                                          strings: strings,
                                        ),
                                      ),
                                      const SizedBox(width: 64),
                                      Expanded(
                                        flex: 9,
                                        child: _MissionDossier(
                                          lang: lang,
                                          strings: strings,
                                          provider: provider,
                                          selectedRoleId: _roleId,
                                          launching: _launching,
                                          onRoleSelected: (id) =>
                                              setState(() => _roleId = id),
                                          onNewGame: () => _newGame(context),
                                          onContinue: () =>
                                              _continueGame(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _Hero(
                                        lang: lang,
                                        strings: strings,
                                        compact: true,
                                      ),
                                      const SizedBox(height: 26),
                                      _MissionDossier(
                                        lang: lang,
                                        strings: strings,
                                        provider: provider,
                                        selectedRoleId: _roleId,
                                        launching: _launching,
                                        onRoleSelected: (id) =>
                                            setState(() => _roleId = id),
                                        onNewGame: () => _newGame(context),
                                        onContinue: () =>
                                            _continueGame(context),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Column(
                        children: [
                          Text(
                            lang == AppLang.de
                                ? 'EIN INTERAKTIVES ZUKUNFTSSZENARIO · KEINE PROGNOSE'
                                : 'AN INTERACTIVE FUTURES SCENARIO · NOT A FORECAST',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textFaint,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.attributionShort,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textFaint,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final GameProvider provider;

  const _TopBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Flexible(child: _BrandMark()),
          const SizedBox(width: 8),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.lineSoft),
            ),
            child: Row(
              children: AppLang.values.map((lang) {
                final selected = provider.appLang == lang;
                return Semantics(
                  selected: selected,
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(7),
                    onTap: () {
                      GameFeedback.navigate(enabled: provider.soundEnabled);
                      provider.setAppLang(lang);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.tealBright.withValues(alpha: .14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        lang.label,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.tealBright
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.tealBright.withValues(alpha: .6),
            ),
          ),
          child: const Icon(
            Icons.blur_on,
            color: AppTheme.tealBright,
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        const Flexible(
          child: Text(
            'SITUATION / ROOM',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final AppLang lang;
  final Strings strings;
  final bool compact;

  const _Hero({
    required this.lang,
    required this.strings,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        StatusPill(
          label: lang == AppLang.de
              ? 'Szenario aktiv · 2026—2040'
              : 'Scenario active · 2026—2040',
          color: AppTheme.tealBright,
          icon: Icons.sensors,
          pulse: true,
        ),
        SizedBox(height: compact ? 18 : 26),
        Stack(
          alignment: compact ? Alignment.center : Alignment.centerLeft,
          children: [
            if (!compact)
              const Positioned(
                right: 0,
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: _OrbitalSignal(),
                ),
              ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.textPrimary, AppTheme.tealBright],
              ).createShader(bounds),
              // Zweizeilige Wortmarke: „COLD" über „COMPUTE".
              child: Text(
                'COLD\nCOMPUTE',
                textAlign: compact ? TextAlign.center : TextAlign.left,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: compact ? 44 : 66,
                  height: .92,
                  letterSpacing: compact ? -1.6 : -2.6,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          strings.subtitle,
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: AppTheme.amber,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 530),
          child: Text(
            strings.intro,
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: compact ? 14 : 16,
            ),
          ),
        ),
        if (compact) ...[
          const SizedBox(height: 22),
          const SizedBox(width: 190, height: 70, child: _OrbitalSignal()),
        ],
      ],
    );
  }
}

class _MissionDossier extends StatelessWidget {
  final AppLang lang;
  final Strings strings;
  final GameProvider provider;
  final String selectedRoleId;
  final bool launching;
  final ValueChanged<String> onRoleSelected;
  final VoidCallback onNewGame;
  final VoidCallback onContinue;

  const _MissionDossier({
    required this.lang,
    required this.strings,
    required this.provider,
    required this.selectedRoleId,
    required this.launching,
    required this.onRoleSelected,
    required this.onNewGame,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      borderColor: AppTheme.teal.withValues(alpha: .28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            lang == AppLang.de ? 'Missionsdossier' : 'Mission dossier',
            color: AppTheme.tealBright,
            trailing: const Text(
              'CLASS // A',
              style: TextStyle(
                color: AppTheme.textFaint,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            strings.chooseRole,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textFaint,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 9),
          ...Scenario.roles.map(
            (role) => _RoleDossierTile(
              role: role,
              lang: lang,
              selected: role.id == selectedRoleId,
              onTap: () {
                GameFeedback.navigate(enabled: provider.soundEnabled);
                onRoleSelected(role.id);
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MissionFact(
                  label: lang == AppLang.de ? 'ZEITRAUM' : 'TIMELINE',
                  value: '14Y / 29T',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MissionFact(
                  label: lang == AppLang.de ? 'AUSGÄNGE' : 'OUTCOMES',
                  value: '07',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MissionFact(
                  label: lang == AppLang.de ? 'KERN' : 'CORE',
                  value: 'W20',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const ValueKey('new_game_button'),
              onPressed: launching ? null : onNewGame,
              icon: launching
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(strings.newGame),
            ),
          ),
          if (provider.hasSave) ...[
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('continue_game_button'),
                onPressed: launching ? null : onContinue,
                icon: const Icon(Icons.restore_rounded, size: 19),
                label: Text(strings.continueGame),
              ),
            ),
          ],
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              key: const ValueKey('codex_button'),
              onPressed: () {
                GameFeedback.navigate(enabled: provider.soundEnabled);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CodexScreen()));
              },
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(strings.codexButton),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              key: const ValueKey('stats_button'),
              onPressed: () {
                GameFeedback.navigate(enabled: provider.soundEnabled);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const StatsScreen()));
              },
              icon: const Icon(Icons.insights_outlined, size: 18),
              label: Text(strings.statsButton),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleDossierTile extends StatelessWidget {
  final Role role;
  final AppLang lang;
  final bool selected;
  final VoidCallback onTap;

  const _RoleDossierTile({
    required this.role,
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.tealBright.withValues(alpha: .07)
                : AppTheme.surface.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppTheme.tealBright.withValues(alpha: .36)
                  : AppTheme.lineSoft,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (selected ? AppTheme.tealBright : AppTheme.textFaint)
                      .withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.policy_outlined,
                  color: selected ? AppTheme.tealBright : AppTheme.textFaint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name.t(lang),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description.t(lang),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppTheme.tealBright : AppTheme.textFaint,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionFact extends StatelessWidget {
  final String label;
  final String value;

  const _MissionFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bg.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textFaint,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitalSignal extends StatelessWidget {
  const _OrbitalSignal();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OrbitalPainter());
  }
}

class _OrbitalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .36;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.tealBright.withValues(alpha: .18);
    canvas.drawCircle(center, radius, line);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * .7),
      line,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * .7, height: radius * 2),
      line,
    );
    for (var i = 0; i < 8; i++) {
      final angle = i / 8 * math.pi * 2;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(
        p,
        i.isEven ? 2.2 : 1.3,
        Paint()..color = i.isEven ? AppTheme.amber : AppTheme.tealBright,
      );
    }
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = AppTheme.tealBright
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
