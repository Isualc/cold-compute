import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/codex_content.dart';
import '../l10n/strings.dart';
import '../models/lang.dart';
import '../providers/game_provider.dart';
import '../theme.dart';
import '../widgets/visual_shell.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<GameProvider>().contentLang;
    final de = lang == AppLang.de;
    final sections = codexSections.where((section) {
      if (_query.trim().isEmpty) return true;
      return section
          .searchText(lang)
          .toLowerCase()
          .contains(_query.trim().toLowerCase());
    }).toList();

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
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings(lang).codexTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            de
                                ? 'REGELWERK · MECHANISMEN · QUELLEN'
                                : 'RULES · MECHANISMS · SOURCES',
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
                          '${sections.length} ${de ? 'Dossiers' : 'dossiers'}',
                      color: AppTheme.textSecondary,
                      icon: Icons.inventory_2_outlined,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: ListView(
                      key: const PageStorageKey('codex_list'),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                      children: [
                        GlassPanel(
                          padding: const EdgeInsets.all(14),
                          blur: false,
                          borderColor: AppTheme.tealBright.withValues(
                            alpha: .18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel(
                                de ? 'Wissensarchiv' : 'Knowledge archive',
                                color: AppTheme.tealBright,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _search,
                                onChanged: (value) =>
                                    setState(() => _query = value),
                                decoration: InputDecoration(
                                  hintText: de
                                      ? 'Mechanismus oder Quelle suchen …'
                                      : 'Search mechanisms or sources …',
                                  hintStyle: const TextStyle(
                                    color: AppTheme.textFaint,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: AppTheme.textSecondary,
                                  ),
                                  suffixIcon: _query.isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            _search.clear();
                                            setState(() => _query = '');
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                        ),
                                  filled: true,
                                  fillColor: AppTheme.bg.withValues(alpha: .62),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.lineSoft,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.lineSoft,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.tealBright,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (sections.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 64),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  color: AppTheme.textFaint,
                                  size: 34,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  de
                                      ? 'Kein Dossier gefunden.'
                                      : 'No dossier found.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        else
                          ...sections.indexed.map(
                            (entry) => _CodexDossier(
                              index: entry.$1,
                              section: entry.$2,
                              lang: lang,
                              initiallyExpanded:
                                  entry.$1 == 0 || _query.isNotEmpty,
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
}

class _CodexDossier extends StatelessWidget {
  final int index;
  final CodexSection section;
  final AppLang lang;
  final bool initiallyExpanded;

  const _CodexDossier({
    required this.index,
    required this.section,
    required this.lang,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final accent = [
      AppTheme.tealBright,
      AppTheme.amber,
      AppTheme.blue,
      AppTheme.covert,
    ][index % 4];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: GlassPanel(
          padding: EdgeInsets.zero,
          blur: false,
          borderColor: accent.withValues(alpha: .17),
          child: ExpansionTile(
            key: PageStorageKey('codex_$index'),
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.fromLTRB(14, 5, 12, 5),
            childrenPadding: const EdgeInsets.fromLTRB(16, 2, 16, 17),
            leading: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            iconColor: accent,
            collapsedIconColor: AppTheme.textFaint,
            title: Text(
              section.title.t(lang),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              for (final block in section.blocks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CodexBlockView(
                    block: block,
                    accent: accent,
                    lang: lang,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rendert einen Codex-Block: Absatz, Bullet-Dossier, Callout oder Kennzahlen.
class _CodexBlockView extends StatelessWidget {
  final CodexBlock block;
  final Color accent;
  final AppLang lang;

  const _CodexBlockView({
    required this.block,
    required this.accent,
    required this.lang,
  });

  /// Zerlegt `**…**`-Markup in TextSpans mit hervorgehobenen Passagen.
  static List<TextSpan> emphasize(
    String text, {
    required Color base,
    required Color strong,
  }) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isStrong = i.isOdd;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: isStrong ? strong : base,
          fontWeight: isStrong ? FontWeight.w700 : FontWeight.w400,
        ),
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    switch (block) {
      case CodexParagraph p:
        return Text.rich(
          TextSpan(
            children: emphasize(
              p.text.t(lang),
              base: AppTheme.textSecondary,
              strong: AppTheme.textPrimary,
            ),
          ),
          style: bodyStyle,
        );

      case CodexBullets b:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in b.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.lead.t(lang),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(text: '   '),
                            ...emphasize(
                              item.text.t(lang),
                              base: AppTheme.textSecondary,
                              strong: AppTheme.textPrimary,
                            ),
                          ],
                        ),
                        style: bodyStyle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

      case CodexCallout c:
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: .14)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 11, 13, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded,
                                  size: 12, color: accent),
                              const SizedBox(width: 5),
                              Text(
                                c.kicker.t(lang).toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text.rich(
                            TextSpan(
                              children: emphasize(
                                c.text.t(lang),
                                base: AppTheme.textSecondary,
                                strong: accent,
                              ),
                            ),
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case CodexStats s:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stat in s.items)
              Container(
                constraints: const BoxConstraints(minWidth: 92),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.bg.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: .22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.value,
                      style: TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat.label.t(lang),
                      style: const TextStyle(
                        color: AppTheme.textFaint,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
    }
  }
}
