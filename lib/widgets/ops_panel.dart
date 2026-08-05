import 'package:flutter/material.dart';

import '../data/directives.dart';
import '../l10n/strings.dart';
import '../models/directive.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../providers/game_provider.dart';
import '../services/game_feedback.dart';
import '../theme.dart';
import 'visual_shell.dart';

/// Einsatzzentrale: verdeckte Direktiven für das laufende Halbjahr.
/// Währung ist Compute (K H100e), Kapazität sind Operationsslots.
class OpsPanel extends StatelessWidget {
  final GameProvider provider;
  final EdgeInsetsGeometry padding;

  const OpsPanel({
    super.key,
    required this.provider,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 108),
  });

  Color _domainColor(OpsDomain domain) => switch (domain) {
        OpsDomain.intel => AppTheme.blue,
        OpsDomain.cyber => AppTheme.tealBright,
        OpsDomain.kinetic => AppTheme.danger,
        OpsDomain.deception => AppTheme.covert,
        OpsDomain.procurement => AppTheme.amber,
        OpsDomain.defensive => AppTheme.green,
        OpsDomain.diplomatic => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('ops_panel'),
      padding: padding,
      children: buildSections(context),
    );
  }

  /// Bausteine der Einsatzzentrale — auch einzeln verwendbar, damit die
  /// mobile Gesamtansicht alles in einem Scroll zeigen kann.
  List<Widget> buildSections(BuildContext context) {
    final state = provider.state!;
    final lang = state.lang;
    final strings = Strings(lang);
    final de = lang == AppLang.de;
    final outcome = provider.lastDirectiveOutcome;

    final available = directives.where((d) => d.isAvailable(state)).toList();

    return [
        _OpsHeader(state: state, strings: strings, de: de),
        if (outcome != null) ...[
          const SizedBox(height: 10),
          _OpsResult(
            directive: provider.lastDirective!,
            outcome: outcome,
            lang: lang,
            color: _domainColor(provider.lastDirective!.domain),
            onDismiss: provider.clearDirectiveOutcome,
          ),
        ],
        const SizedBox(height: 12),
        SectionLabel(
          de
              ? 'Verfügbare Direktiven (${available.length})'
              : 'Available directives (${available.length})',
          color: AppTheme.tealBright,
        ),
        const SizedBox(height: 9),
        if (state.opsSlotsLeft <= 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              strings.opsSpent,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.amber,
                  ),
            ),
          ),
      ...available.map(
        (directive) => _DirectiveCard(
          directive: directive,
          state: state,
          strings: strings,
          color: _domainColor(directive.domain),
          enabled: provider.engine.canRunDirective(state, directive),
          onExecute: () {
            GameFeedback.decision(enabled: provider.soundEnabled);
            provider.runDirective(directive);
          },
        ),
      ),
    ];
  }
}

class _OpsHeader extends StatelessWidget {
  final GameState state;
  final Strings strings;
  final bool de;

  const _OpsHeader({
    required this.state,
    required this.strings,
    required this.de,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      blur: false,
      borderColor: AppTheme.danger.withValues(alpha: .2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(strings.opsTitle, color: AppTheme.danger),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _OpsStat(
                  value: '${state.compute.round()}K',
                  unit: 'H100e',
                  label: strings.opsBudget,
                  color: AppTheme.amber,
                  icon: Icons.memory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OpsStat(
                  value:
                      '${state.opsSlotsLeft}/${GameState.opsSlotsPerTurn}',
                  unit: state.turnLabel,
                  label: strings.opsSlots,
                  color: AppTheme.tealBright,
                  icon: Icons.groups_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            de
                ? 'Compute ist die Währung: Rechenzeit kauft Quellen, '
                    'bezahlt Mittelsmänner und finanziert Programme, die in '
                    'keinem Haushalt stehen. Jeder Einsatz kann auffliegen — '
                    'Attribution treibt die Eskalationsleiter nach oben.'
                : 'Compute is the currency: compute time buys sources, pays '
                    'cutouts and funds programs that appear in no budget. '
                    'Every operation can be blown — attribution drives the '
                    'escalation ladder up.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _OpsStat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color color;
  final IconData icon;

  const _OpsStat({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bg.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppTheme.textFaint,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textFaint,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpsResult extends StatelessWidget {
  final Directive directive;
  final DirectiveOutcome outcome;
  final AppLang lang;
  final Color color;
  final VoidCallback onDismiss;

  const _OpsResult({
    required this.directive,
    required this.outcome,
    required this.lang,
    required this.color,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final de = lang == AppLang.de;
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      blur: false,
      borderColor: color.withValues(alpha: .4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 15, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  de ? 'EINSATZBERICHT' : 'AFTER-ACTION REPORT',
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, size: 16),
                color: AppTheme.textFaint,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            directive.name.t(lang),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            outcome.text.t(lang),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _DirectiveCard extends StatelessWidget {
  final Directive directive;
  final GameState state;
  final Strings strings;
  final Color color;
  final bool enabled;
  final VoidCallback onExecute;

  const _DirectiveCard({
    required this.directive,
    required this.state,
    required this.strings,
    required this.color,
    required this.enabled,
    required this.onExecute,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.lang;
    final success = directive.successChance(state);
    final exposure = directive.exposureChance(state);
    final affordable = state.compute >= directive.computeCost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GlassPanel(
        padding: const EdgeInsets.all(13),
        blur: false,
        borderColor: color.withValues(alpha: enabled ? .28 : .12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    directive.domain.code,
                    style: TextStyle(
                      color: color,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    directive.name.t(lang),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: enabled
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                  ),
                ),
                if (directive.oneShot)
                  Tooltip(
                    message: lang == AppLang.de
                        ? 'Nur einmal pro Partie'
                        : 'Once per run',
                    child: const Icon(
                      Icons.looks_one_outlined,
                      size: 15,
                      color: AppTheme.textFaint,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              directive.description.t(lang),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Chip(
                  label: strings.opsCost,
                  value: '${directive.computeCost.round()}K',
                  color: affordable ? AppTheme.amber : AppTheme.danger,
                ),
                const SizedBox(width: 6),
                _Chip(
                  label: strings.opsChance,
                  value: '$success %',
                  color: AppTheme.green,
                ),
                const SizedBox(width: 6),
                _Chip(
                  label: strings.opsExposure,
                  value: '$exposure %',
                  color: AppTheme.covert,
                ),
                if (directive.slots > 1) ...[
                  const SizedBox(width: 6),
                  _Chip(
                    label: strings.opsSlots,
                    value: '${directive.slots}',
                    color: AppTheme.tealBright,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('directive_${directive.id}'),
                onPressed: enabled ? onExecute : null,
                icon: const Icon(Icons.bolt_rounded, size: 17),
                label: Text(
                  enabled ? strings.opsExecute : strings.opsNoBudget,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(
                    color: color.withValues(alpha: enabled ? .5 : .16),
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

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Chip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bg.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textFaint,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
