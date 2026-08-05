import '../models/lang.dart';

/// Nachschlagewerk im Spiel: Hintergrund, Regelwerk, Quellen.
/// Alle Zahlen stammen aus ai-2040.com samt Supplements (Stand Juli 2026).
///
/// Redaktionelles Block-Modell statt Textwänden: Absätze (mit **Hervor-
/// hebungen**), Bullet-Dossiers, Mechanik-Callouts und Zahlen-Chips.
sealed class CodexBlock {
  const CodexBlock();
}

/// Fließtext-Absatz. `**…**` markiert hervorgehobene Begriffe/Zahlen.
class CodexParagraph extends CodexBlock {
  final LText text;
  const CodexParagraph(this.text);
}

/// Ein Eintrag eines Bullet-Dossiers: fetter Leitbegriff + Erläuterung.
class CodexBullet {
  final LText lead;
  final LText text;
  const CodexBullet(this.lead, this.text);
}

class CodexBullets extends CodexBlock {
  final List<CodexBullet> items;
  const CodexBullets(this.items);
}

/// Hervorgehobener Kasten, z. B. für Spielmechanik oder Originalzitate.
class CodexCallout extends CodexBlock {
  final LText kicker;
  final LText text;
  const CodexCallout(this.kicker, this.text);
}

/// Kennzahl-Chip: großer Wert + kleine Beschriftung.
class CodexStat {
  final String value;
  final LText label;
  const CodexStat(this.value, this.label);
}

class CodexStats extends CodexBlock {
  final List<CodexStat> items;
  const CodexStats(this.items);
}

class CodexSection {
  final LText title;
  final List<CodexBlock> blocks;
  const CodexSection(this.title, this.blocks);

  /// Durchsuchbarer Gesamttext der Sektion.
  String searchText(AppLang lang) {
    final buffer = StringBuffer(title.t(lang));
    for (final block in blocks) {
      switch (block) {
        case CodexParagraph p:
          buffer.write(' ${p.text.t(lang)}');
        case CodexBullets b:
          for (final item in b.items) {
            buffer.write(' ${item.lead.t(lang)} ${item.text.t(lang)}');
          }
        case CodexCallout c:
          buffer.write(' ${c.kicker.t(lang)} ${c.text.t(lang)}');
        case CodexStats s:
          for (final item in s.items) {
            buffer.write(' ${item.value} ${item.label.t(lang)}');
          }
      }
    }
    return buffer.toString();
  }
}

const LText _mechanic = LText('Spielmechanik', 'Game mechanic');
const LText _quote = LText('Originalton', 'Source quote');

const List<CodexSection> codexSections = [
  // ── 1 ── Das Szenario ────────────────────────────────────────────────
  CodexSection(
    LText('Das Szenario: AI 2040 — Plan A', 'The Scenario: AI 2040 — Plan A'),
    [
      CodexParagraph(LText(
        '**AI 2040: Plan A** erschien am **9. Juli 2026** beim '
            '**AI Futures Project** (Larsen, Dean, Halstead, Lifland, '
            'Greenblatt, Kokotajlo) — den Autoren von AI 2027. Anders als '
            'der Vorgänger ist es keine Prognose, sondern ein '
            '**Wunschpfad**: Wie könnte die Welt die Superintelligenz '
            'absichtlich auf 2040 verschieben, statt sie um 2030 im Rennen '
            'zu erreichen?',
        '**AI 2040: Plan A** was published on **July 9, 2026** by the '
            '**AI Futures Project** (Larsen, Dean, Halstead, Lifland, '
            'Greenblatt, Kokotajlo) — the authors of AI 2027. Unlike its '
            'predecessor it is not a forecast but a **wish path**: how '
            'could the world deliberately push superintelligence back to '
            '2040, instead of reaching it around 2030 in a race?',
      )),
      CodexStats([
        CodexStat('2029', LText('US-China-Abkommen', 'US–China treaty')),
        CodexStat('2035', LText('Pause auf TED-AI', 'Pause at TED-AI')),
        CodexStat('2040', LText('Kontrollierte ASI', 'Controlled ASI')),
      ]),
      CodexParagraph(LText(
        'Der Kern: 2029 schließen USA und China ein Abkommen — volle '
            '**Forschungstransparenz**, **Chip-Tracking**, gegenseitige '
            '**Inspektionen**. Die Entwicklung wird gedrosselt, pausiert '
            '2035 auf dem Niveau menschlicher Top-Experten und geht erst '
            '2040, nach einem Jahrzehnt Alignment-Forschung, den letzten '
            'Schritt.',
        'The core: in 2029 the US and China sign a treaty — full '
            '**research transparency**, **chip tracking**, mutual '
            '**inspections**. Development is throttled, pauses in 2035 at '
            'the level of top human experts, and takes the final step only '
            'in 2040, after a decade of alignment research.',
      )),
      CodexCallout(_quote, LText(
        '„Plan A wird umgesetzt — unvollkommen und gerade noch '
            'rechtzeitig."',
        '"Plan A is implemented successfully, albeit imperfectly and only '
            'in the nick of time."',
      )),
    ],
  ),

  // ── 2 ── Die fünf Pläne ──────────────────────────────────────────────
  CodexSection(
    LText('Die fünf Pläne von 2029', 'The Five Plans of 2029'),
    [
      CodexParagraph(LText(
        'Der zentrale Entscheidungspunkt des Originals. Die Autoren '
            'beziffern jeden Pfad mit **Takeoff-Länge**, '
            '**p(Alignment)** und **p(großartige Zukunft)**:',
        'The original\'s central decision point. The authors score every '
            'path with **takeoff length**, **p(alignment)** and **p(great '
            'future)**:',
      )),
      CodexBullets([
        CodexBullet(
          LText('Plan A — The Deal', 'Plan A — The Deal'),
          LText(
            'Verified Slowdown: **6 Jahre** Takeoff · **72 %** · **42 %**. '
                'Die einzige Empfehlung der Autoren.',
            'Verified Slowdown: **6-year** takeoff · **72%** · **42%**. '
                'The authors\' only recommendation.',
          ),
        ),
        CodexBullet(
          LText('Plan B — Fight China', 'Plan B — Fight China'),
          LText(
            '**2–3 Jahre** · **~50 %** · **25 %**. Sabotage kauft Monate, '
                'riskiert Krieg und Machtkonzentration.',
            '**2–3 years** · **~50%** · **25%**. Sabotage buys months, '
                'risks war and power concentration.',
          ),
        ),
        CodexBullet(
          LText('Plan C — Burn the Lead', 'Plan C — Burn the Lead'),
          LText(
            '**1,5 Jahre** · **~40 %** · **20 %**. Das führende Lab '
                'verbrennt freiwillig seinen Vorsprung; im Original bricht '
                'die Pause nach Monaten zusammen.',
            '**1.5 years** · **~40%** · **20%**. The leading lab '
                'voluntarily burns its head start; in the original the '
                'pause collapses within months.',
          ),
        ),
        CodexBullet(
          LText('Plan C+ — Domestic Regulation',
              'Plan C+ — Domestic Regulation'),
          LText(
            '**2 Jahre** · **~45 %** · **25 %**. Staatliche Regeln ohne '
                'China-Deal.',
            '**2 years** · **~45%** · **25%**. State-level rules with no '
                'China deal.',
          ),
        ),
        CodexBullet(
          LText('Plan D — Race to ASI', 'Plan D — Race to ASI'),
          LText(
            '**1,13 Jahre** · **25 %** · **10 %**. Volles Tempo — das '
                'Race-Ende von AI 2027.',
            '**1.13 years** · **25%** · **10%**. Full speed ahead — the '
                'Race ending of AI 2027.',
          ),
        ),
        CodexBullet(
          LText('Plan S — Shut it all down', 'Plan S — Shut it all down'),
          LText(
            'Globales Moratorium. Möglicherweise besser als Plan A, '
                'urteilen die Autoren — aber ohne Frontier-Skalierung fehlt '
                'auch das Werkzeug für Alignment- und '
                'Verifikationsforschung.',
            'A global moratorium. Possibly better than Plan A, the authors '
                'judge — but without frontier scaling, the very tools for '
                'alignment and verification research are missing too.',
          ),
        ),
      ]),
      CodexCallout(_mechanic, LText(
        'Der Fork **„2029: Choose a Path"** ist die zentrale Entscheidung '
            'jeder Partie. Nur Plan A führt in den vollen Pfad bis 2040 — '
            'die vier anderen Pläne haben eigene Ereignisketten und Enden.',
        'The **"2029: Choose a Path"** fork is the central decision of '
            'every run. Only Plan A leads into the full path to 2040 — the '
            'other four plans have their own event chains and endings.',
      )),
    ],
  ),

  // ── 3 ── Vertragsmechanismen ─────────────────────────────────────────
  CodexSection(
    LText('Die Mechanismen des Vertrags', 'The Mechanics of the Treaty'),
    [
      CodexBullets([
        CodexBullet(
          LText('Transparenz & Verifikation', 'Transparency & verification'),
          LText(
            'Januar 2029 deklarieren beide Seiten ihre Chips (USA: '
                '**224 Mio. H100e**, 77 % der Welt; China: **26 Mio.**, '
                '9 %). Ein paar hundert Inspektoren je Land, passive '
                '**Netzwerk-Taps** in jedem Rechenzentrum, jede Rechenlast '
                'als reproduzierbares **Workload-Paket** mit '
                'Vorab-Freigabe.',
            'In January 2029 both sides declare their chips (US: '
                '**224M H100e**, 77% of the world; China: **26M**, 9%). A '
                'few hundred inspectors per country, passive **network '
                'taps** in every data center, every compute load run as a '
                'reproducible **workload package** with prior clearance.',
          ),
        ),
        CodexBullet(
          LText('Gegenseitige Geiseln', 'Mutual hostages'),
          LText(
            'Rechenzentren an bewusst verwundbaren Standorten, '
                'Chipfabriken in zerstörbaren '
                '**Sonderwirtschaftszonen**, gehärtete Kaltreserven von '
                '**2 %** des Computes je Seite.',
            'Data centers at deliberately vulnerable locations, chip fabs '
                'in destructible **special economic zones**, hardened cold '
                'reserves of **2%** of each side\'s compute.',
          ),
        ),
        CodexBullet(
          LText('Mutually Assured Compute Destruction',
              'Mutually Assured Compute Destruction'),
          LText(
            'Bei nachgewiesenem Ausbruch darf die Nachvertrags-Hardware '
                'des Vertragsbrechers zerstört werden. Greift der '
                'Mechanismus: Takeoff **~1 Jahr**. Greift er nicht: '
                'Compute-Überhang, bis zu **40-fach** schneller — '
                '**9 Tage**.',
            'On proven breakout, the treaty-breaker\'s post-treaty '
                'hardware may be destroyed. If the mechanism holds: takeoff '
                'in **~1 year**. If not: compute overhang, up to **40×** '
                'faster — **9 days**.',
          ),
        ),
      ]),
      CodexStats([
        CodexStat('2030', LText('Kontrolle pro Server', 'Control per server')),
        CodexStat('2032', LText('pro Rack', 'per rack')),
        CodexStat('2034', LText('pro GPU', 'per GPU')),
      ]),
      CodexCallout(_mechanic, LText(
        'Ab 2034 fliegt ein illegales Deployment von **10.000 H100e** mit '
            '**99 %** Sicherheit binnen **~5 Stunden** auf. In der '
            'Simulation: Hohe **Verifikation** senkt das Risiko verdeckter '
            'Projekte Runde für Runde — niedrige lässt es wachsen.',
        'From 2034 on, an illegal deployment of **10,000 H100e** is caught '
            'with **99%** certainty within **~5 hours**. In the '
            'simulation: high **verification** lowers covert-project risk '
            'every turn — low verification lets it grow.',
      )),
    ],
  ),

  // ── 4 ── Deal Decline ────────────────────────────────────────────────
  CodexSection(
    LText('Deal Decline — die Sollbruchstellen',
        'Deal Decline — the Fault Lines'),
    [
      CodexParagraph(LText(
        'Der Vertrag ist kein Selbstläufer. Das Supplement **„Deal '
            'Decline"** beziffert das jährliche Zerfallsrisiko — die '
            'Hälfte davon ist kein formaler Bruch, sondern schleichende '
            'Erosion (**Impairment**).',
        'The treaty is not self-sustaining. The **"Deal Decline"** '
            'supplement quantifies the annual risk of decay — half of it '
            'is not a formal rupture but creeping erosion '
            '(**impairment**).',
      )),
      CodexStats([
        CodexStat('11,6 %',
            LText('pro Jahr, Jahre 0–2', 'per year, years 0–2')),
        CodexStat('6,9 %', LText('Jahre 2–5', 'years 2–5')),
        CodexStat('4,0 %', LText('ab Jahr 5', 'from year 5')),
        CodexStat('51 %', LText('kumulativ bis 2040', 'cumulative by 2040')),
      ]),
      CodexBullets([
        CodexBullet(
          LText('Regimewechsel', 'Regime change'),
          LText(
            'Die gefährlichsten Momente sind geplant: **US-Wahlen 2032 '
                'und 2036**, chinesische Nachfolge um **2033**.',
            'The most dangerous moments are scheduled: **US elections '
                '2032 and 2036**, Chinese succession around **2033**.',
          ),
        ),
        CodexBullet(
          LText('Weitere Auslöser', 'Other triggers'),
          LText(
            'Geopolitische Schocks, ertappte Betrüger, schwindende Angst '
                'vor der Superintelligenz.',
            'Geopolitical shocks, cheaters caught in the act, fading fear '
                'of superintelligence.',
          ),
        ),
      ]),
      CodexCallout(_mechanic, LText(
        '**„The later, the better"** — je später der Bruch, desto mehr '
            'Alignment-Fortschritt ist gerettet. In der Simulation senken '
            '**Vertrauen**, **Verifikation** und **politisches Kapital** '
            'die Zerfallsrate; Vernachlässigung erhöht sie.',
        '**"The later, the better"** — the later the break, the more '
            'alignment progress is preserved. In the simulation, '
            '**trust**, **verification** and **political capital** lower '
            'the decay rate; neglect raises it.',
      )),
    ],
  ),

  // ── 5 ── Verdeckte Projekte ──────────────────────────────────────────
  CodexSection(
    LText('Verdeckte Projekte', 'Covert Projects'),
    [
      CodexParagraph(LText(
        'Ein verdecktes Frontier-Projekt müsste vor den Deklarationen von '
            '2029 beginnen. Plausible Größe laut Szenario: **~1,5 Mio. '
            'H100e** (etwa **15 Mrd. Dollar**) — 24-mal weniger Compute '
            'als das größte legale Projekt.',
        'A covert frontier project would have to start before the 2029 '
            'declarations. Plausible size per the scenario: **~1.5M '
            'H100e** (about **\$15B**) — 24 times less compute than the '
            'largest legal project.',
      )),
      CodexBullets([
        CodexBullet(
          LText('Wärmesignaturen', 'Thermal signatures'),
          LText(
            'Jedes Megawatt Strom wird zu einem Megawatt Abwärme — '
                'Infrarot-Satelliten sehen Kühltürme, Wasserdampf, '
                'Fluss-Erwärmung.',
            'Every megawatt of power becomes a megawatt of waste heat — '
                'infrared satellites see cooling towers, steam plumes, '
                'warming rivers.',
          ),
        ),
        CodexBullet(
          LText('Aufklärung & Menschen', 'Intelligence & people'),
          LText(
            'Satelliten-Interferometrie in der Bauphase, Cyberaufklärung '
                'gegen Zulieferer, Whistleblower-Programme.',
            'Satellite interferometry during construction, cyber '
                'reconnaissance against suppliers, whistleblower programs.',
          ),
        ),
        CodexBullet(
          LText('KI-Lügendetektoren', 'AI lie detectors'),
          LText(
            'Ab ~2033 mit **65 %** Wahrscheinlichkeit verfügbar — das '
                'stärkste Upgrade des Verifikationsregimes.',
            'Available from ~2033 with **65%** probability — the '
                'strongest upgrade to the verification regime.',
          ),
        ),
      ]),
      CodexCallout(_mechanic, LText(
        'Eine einzelne **Gigawatt-Anlage** fliegt binnen drei Jahren mit '
            '**~40 %** Wahrscheinlichkeit auf, binnen zehn Jahren mit '
            '**50–90 %**. Gesamtrisiko, dass ein verdecktes Projekt '
            'unentdeckt eine vertragsuntergrabende KI erreicht: **~13 %**.',
        'A single **gigawatt facility** is discovered within three years '
            'with **~40%** probability, within ten years with **50–90%**. '
            'Overall risk that a covert project reaches deal-undermining '
            'AI undetected: **~13%**.',
      )),
    ],
  ),

  // ── 6 ── Meilensteine ────────────────────────────────────────────────
  CodexSection(
    LText('Meilensteine der Fähigkeits-Skala',
        'Milestones of the Capability Scale'),
    [
      CodexParagraph(LText(
        'Die Simulation misst KI-Fähigkeit von **0 bis 100**, angelehnt '
            'an die Meilensteine des AI Futures Project — mit dem '
            'jeweiligen Forschungs-Beschleunigungsfaktor:',
        'The simulation measures AI capability from **0 to 100**, mapped '
            'to the AI Futures Project milestones — each with its research '
            'acceleration factor:',
      )),
      CodexBullets([
        CodexBullet(
          LText('30 — Übermenschlicher Programmierer',
              '30 — Superhuman coder'),
          LText(
            'Automated Coder, **~3-facher** F&E-Uplift; im Szenario '
                '~Januar 2030.',
            'Automated Coder, **~3×** R&D uplift; ~January 2030 in the '
                'scenario.',
          ),
        ),
        CodexBullet(
          LText('55 — Übermenschlicher KI-Forscher',
              '55 — Superhuman AI researcher'),
          LText('**~20-facher** Uplift.', '**~20×** uplift.'),
        ),
        CodexBullet(
          LText('75 — TED-AI (Pausenlinie)', '75 — TED-AI (pause line)'),
          LText(
            'Top-Expert-Dominating AI, **~40-fach**, erreicht ~2035. Das '
                'höchste Niveau, auf dem Kontrolle sicher bleibt — selbst '
                'wenn das System fehlausgerichtet wäre.',
            'Top-Expert-Dominating AI, **~40×**, reached ~2035. The '
                'highest level at which control stays assured — even if '
                'the system were misaligned.',
          ),
        ),
        CodexBullet(
          LText('100 — Superintelligenz', '100 — Superintelligence'),
          LText(
            'Jenseits davon: „wildly superintelligent", **10.000-fach**.',
            'Beyond it: "wildly superintelligent," **10,000×**.',
          ),
        ),
      ]),
    ],
  ),

  // ── 7 ── Ökonomie ────────────────────────────────────────────────────
  CodexSection(
    LText('Die Ökonomie von Plan A', 'The Economics of Plan A'),
    [
      CodexParagraph(LText(
        'Drosselung heißt nicht Stillstand: Unterhalb der Frontier wächst '
            'die Weltwirtschaft 2032–2037 um **~90 % pro Jahr**, bis 2040 '
            'rund **200-fach**. Compute- und Roboter-Permits ersetzen das '
            'Steuersystem und speisen eine **Bürgerdividende**.',
        'Throttling is not stagnation: below the frontier, the world '
            'economy grows **~90% per year** in 2032–2037, roughly '
            '**200×** by 2040. Compute and robot permits replace the tax '
            'system and fund a **citizen\'s dividend**.',
      )),
      CodexStats([
        CodexStat('180 Bio. \$',
            LText('Permit-Einnahmen 2034', 'permit revenue 2034')),
        CodexStat('1 Mio. \$',
            LText('Dividende/Jahr ab 2035', 'dividend/year from 2035')),
        CodexStat('10 Mio. \$',
            LText('Dividende/Jahr ab 2040', 'dividend/year from 2040')),
      ]),
      CodexCallout(_mechanic, LText(
        'Die Dividende ist Spielmechanik: Sie beschafft dem Vertrag '
            '**politisches Kapital** — Millionen Menschen, deren Wohlstand '
            'am Abkommen hängt, sind seine beste Versicherung.',
        'The dividend is a game mechanic: it buys the treaty **political '
            'capital** — millions of people whose prosperity depends on '
            'the deal are its best insurance.',
      )),
    ],
  ),

  // ── 8 ── Spielablauf ─────────────────────────────────────────────────
  CodexSection(
    LText('So spielt sich die Simulation', 'How the Simulation Plays'),
    [
      CodexBullets([
        CodexBullet(
          LText('Runde = Halbjahr', 'Turn = half-year'),
          LText(
            'Von **H2 2026** bis **H2 2040**. Jede Runde entwickelt der '
                'Spielleiter (die Engine) die Weltlage weiter.',
            'From **H2 2026** to **H2 2040**. Every turn, the game master '
                '(the engine) advances the world state.',
          ),
        ),
        CodexBullet(
          LText('Ereigniskarten', 'Event cards'),
          LText(
            'Nachrichten und Entscheidungen — ausgelöst durch Zeitfenster '
                'und Weltlage (Flags, Metriken, Vertragsphase).',
            'News and decisions — triggered by time windows and world '
                'state (flags, metrics, treaty phase).',
          ),
        ),
        CodexBullet(
          LText('W20-Adjudikation', 'd20 adjudication'),
          LText(
            'Du wählst eine Option, der Würfel entscheidet über den '
                'Ausgang. Gute Politik verschiebt die '
                'Wahrscheinlichkeiten — garantiert aber nichts.',
            'You pick an option, the die decides the outcome. Good policy '
                'shifts the odds — but guarantees nothing.',
          ),
        ),
      ]),
      CodexParagraph(LText(
        'Das Vorbild ist die **Tabletop Exercise** des AI Futures '
            'Project: moderiertes Rollenspiel mit **8–14 Teilnehmern** '
            '(US-Präsident, Lab-CEO, China, das Alignment-Team — und die '
            'KI selbst), in dem der Facilitator unsichere Ausgänge per '
            '**Wahrscheinlichkeits-Poll und Würfel** entscheidet. Ein '
            'offizielles Regelwerk existiert nicht; diese Simulation '
            'überträgt das Adjudikationsprinzip auf AI 2040.',
        'The model is the AI Futures Project **tabletop exercise**: '
            'facilitated role-play with **8–14 participants** (US '
            'President, lab CEO, China, the alignment team — and the AI '
            'itself), where the facilitator resolves uncertain outcomes '
            'via **probability poll and dice**. No official rulebook '
            'exists; this simulation transfers that adjudication principle '
            'to AI 2040.',
      )),
      CodexCallout(_quote, LText(
        '„Die meisten Iterationen enden mit der Entwicklung von '
            'Superintelligenz … es gibt immer Cyberangriffe, manchmal wird '
            'Taiwan invadiert, und in einigen Fällen eskaliert es zum '
            'Dritten Weltkrieg."',
        '"Most iterations of the exercise finish with the development of '
            'superintelligence … there are always cyberattacks, sometimes '
            'Taiwan gets invaded, and in a few cases there\'s escalation '
            'to a full World War 3."',
      )),
    ],
  ),

  // ── 9 ── Verdeckte Operationen ───────────────────────────────────────
  CodexSection(
    LText('Verdeckte Operationen', 'Covert Operations'),
    [
      CodexParagraph(LText(
        'Zwischen den großen Entscheidungen läuft der Alltag eines '
            'Sicherheitsapparats weiter. Jedes Halbjahr hast du '
            '**zwei Operationsslots** und ein verdecktes '
            '**Compute-Budget in K H100e** — Rechenzeit ist in diesem '
            'Szenario die harte Währung: Sie kauft Quellen, bezahlt '
            'Mittelsmänner und finanziert Programme, die in keinem '
            'Haushaltsplan stehen.',
        'Between the big decisions, the daily work of a security apparatus '
            'goes on. Every half-year you get **two operation slots** and a '
            'covert **compute budget in K H100e** — compute time is the hard '
            'currency in this scenario: it buys sources, pays cutouts and '
            'funds programs that appear in no budget.',
      )),
      CodexBullets([
        CodexBullet(
          LText('Aufklärung (INT)', 'Intelligence (INT)'),
          LText(
            'SIGINT gegen Lieferketten, thermale Satellitenaufklärung, '
                'HUMINT-Quellen. Hebt die **Aufklärungslage** — und die '
                'verbessert Erfolgschancen aller weiteren Operationen.',
            'SIGINT against supply chains, thermal satellite '
                'reconnaissance, HUMINT sources. Raises the **intelligence '
                'picture** — which improves the odds of every other '
                'operation.',
          ),
        ),
        CodexBullet(
          LText('Cyber & verdeckte Aktion', 'Cyber & covert action'),
          LText(
            'Sabotage an Kühlkreisläufen, Exfiltration, Eingriffe in die '
                'Fab-Lieferkette. Kauft Zeit gegen den Wettlauf, treibt '
                'aber die **Eskalation**.',
            'Cooling-loop sabotage, exfiltration, interference in the fab '
                'supply chain. Buys time against the race but drives '
                '**escalation**.',
          ),
        ),
        CodexBullet(
          LText('Täuschung (DEC)', 'Deception (DEC)'),
          LText(
            'Desinformation über eigene Fähigkeiten — und die '
                '**False-Flag-Operation**: hoher Ertrag, das höchste '
                'Attributionsrisiko im Katalog. Fliegt sie auf, ist der '
                'Schaden am Vertrauen kaum reparabel.',
            'Disinformation about our own capabilities — and the **false '
                'flag operation**: high yield, the highest attribution risk '
                'in the catalog. If it is blown, the damage to trust is '
                'barely repairable.',
          ),
        ),
        CodexBullet(
          LText('Beschaffung (PRO)', 'Procurement (PRO)'),
          LText(
            '**Datenkauf** über Mittelsmänner hebt die eigene Fähigkeit; '
                'der Grauimport von Beschleunigern bringt zusätzliches '
                'Compute ins Budget — und finanziert die Netzwerke, die '
                'man eigentlich bekämpft.',
            '**Data purchases** through cutouts raise our own capability; '
                'gray-market accelerator imports add compute to the budget '
                '— and fund the very networks we are fighting.',
          ),
        ),
        CodexBullet(
          LText('Abwehr & Diplomatie', 'Defense & diplomacy'),
          LText(
            'Spionageabwehr-Sweeps und Cluster-Härtung stärken die '
                '**Verifikation**; Deeskalations-Draht und gemeinsame '
                'Vorfalluntersuchung senken die **Eskalation**.',
            'Counterintelligence sweeps and cluster hardening strengthen '
                '**verification**; deconfliction lines and joint incident '
                'reviews lower **escalation**.',
          ),
        ),
      ]),
      CodexCallout(_mechanic, LText(
        'Jede Direktive wird mit dem W20 gegen ihre Erfolgschance '
            'ausgewürfelt. Bei einem Fehlschlag folgt ein **zweiter Wurf '
            'auf Attribution** — nicht jede gescheiterte Operation fliegt '
            'auf. Ein scharfes gegnerisches Verifikationsregime senkt die '
            'Erfolgschance und erhöht das Attributionsrisiko: Je besser die '
            'Welt kontrolliert, desto teurer wird verdecktes Handeln.',
        'Every directive is rolled on a d20 against its success chance. On '
            'failure, a **second roll decides attribution** — not every '
            'failed operation gets traced. A sharp adversary verification '
            'regime lowers success odds and raises attribution risk: the '
            'better the world is monitored, the more expensive covert '
            'action becomes.',
      )),
      CodexCallout(_mechanic, LText(
        'Die **Eskalationsstufe** ist eine Leiter mit oberem Ende: Bei '
            '**100** endet die Partie im Krieg. Sie kühlt jedes Halbjahr '
            'ab — schneller unter einem funktionierenden Vertrag, kaum noch '
            'nach dessen Zusammenbruch.',
        'The **escalation level** is a ladder with a top rung: at **100** '
            'the run ends in war. It cools every half-year — faster under a '
            'working treaty, barely at all after its collapse.',
      )),
    ],
  ),

  // ── 10 ── Die Enden ──────────────────────────────────────────────────
  CodexSection(
    LText('Die Enden', 'The Endings'),
    [
      CodexBullets([
        CodexBullet(
          LText('Der Lichtkegel', 'The Lightcone'),
          LText(
            'Plan A gelingt: kontrollierte Superintelligenz 2040 unter '
                'menschlicher Aufsicht.',
            'Plan A succeeds: controlled superintelligence in 2040 under '
                'human oversight.',
          ),
        ),
        CodexBullet(
          LText('Die lange Pause', 'The long pause'),
          LText(
            'Der Vertrag hält, aber der Aufstieg unterbleibt — ein '
                'fragiler Dauerzustand.',
            'The treaty holds, but the ascent never comes — a fragile '
                'steady state.',
          ),
        ),
        CodexBullet(
          LText('Die Welt im Wartestand', 'The world on hold'),
          LText(
            'Das Plan-S-Moratorium trägt bis über 2040 hinaus.',
            'The Plan S moratorium carries past 2040.',
          ),
        ),
        CodexBullet(
          LText('Die Ausgerichteten', 'The aligned few'),
          LText(
            'Die Superintelligenz gehorcht — aber nur einem sehr kleinen '
                'Kreis: die KI-gestützte Oligarchie, vor der die Autoren '
                'bei Plan B/C/D warnen.',
            'Superintelligence obeys — but only a very small circle: the '
                'AI-enforced oligarchy the authors warn about for Plans '
                'B/C/D.',
          ),
        ),
        CodexBullet(
          LText('Das Rennen endet ohne uns', 'The race ends without us'),
          LText(
            'Kontrollverlust durch ungebremsten Wettlauf — das Race-Ende '
                'von AI 2027.',
            'Loss of control through an unchecked race — the Race ending '
                'of AI 2027.',
          ),
        ),
        CodexBullet(
          LText('Der verdeckte Durchbruch', 'The covert breakout'),
          LText(
            'Ein Geheimprogramm erreicht die Superintelligenz an allen '
                'Kontrollen vorbei.',
            'A secret program reaches superintelligence past every '
                'control.',
          ),
        ),
        CodexBullet(
          LText('Eskalation', 'Escalation'),
          LText(
            'Die Abschreckungslogik kippt in den heißen Krieg.',
            'The deterrence logic tips into hot war.',
          ),
        ),
      ]),
    ],
  ),

  // ── 11 ── Quellen ────────────────────────────────────────────────────
  CodexSection(
    LText('Quellen & Rechtliches', 'Sources & legal'),
    [
      CodexCallout(
        LText('Unabhängiges Projekt', 'Independent project'),
        LText(
          '**Cold Compute** ist ein unabhängiges Fan-Projekt von **isualc '
              'AI**. Es setzt das öffentlich veröffentlichte Szenario '
              '**„AI 2040: Plan A"** des **AI Futures Project** spielerisch '
              'um und nennt es als Quelle. Eine Verbindung zum AI Futures '
              'Project besteht nicht; das Projekt hat diese Umsetzung weder '
              'geprüft noch unterstützt. Alle Szenario-Inhalte sind eigene '
              'Formulierungen, die genannten Zahlen stammen als Fakten aus '
              'den frei zugänglichen Papieren.',
          '**Cold Compute** is an independent fan project by **isualc AI**. '
              'It turns the publicly published scenario **"AI 2040: Plan A"** '
              'by the **AI Futures Project** into a game and credits it as '
              'its source. There is no affiliation with the AI Futures '
              'Project; they have neither reviewed nor endorsed this '
              'adaptation. All scenario text is original writing; the figures '
              'quoted are facts taken from the freely available papers.',
        ),
      ),
      CodexBullets([
        CodexBullet(
          LText('ai-2040.com', 'ai-2040.com'),
          LText(
            'AI 2040: Plan A (AI Futures Project, 9. Juli 2026) mit den '
                'Supplements Verification Plan, Deal Decline, Covert AI '
                'Projects, Comparing Possible Plans, Economics of Plan A, '
                'Capability Scaling Strategy u. a.',
            'AI 2040: Plan A (AI Futures Project, July 9, 2026) with the '
                'supplements Verification Plan, Deal Decline, Covert AI '
                'Projects, Comparing Possible Plans, Economics of Plan A, '
                'Capability Scaling Strategy and more.',
          ),
        ),
        CodexBullet(
          LText('ai-2027.com', 'ai-2027.com'),
          LText(
            'Das Vorgänger-Szenario mit den Enden „Race" und „Slowdown"; '
                'die Pläne B/C/D von AI 2040 verweisen direkt darauf.',
            'The predecessor scenario with the "Race" and "Slowdown" '
                'endings; AI 2040\'s Plans B/C/D point straight at it.',
          ),
        ),
        CodexBullet(
          LText('Tabletop Exercise', 'Tabletop exercise'),
          LText(
            'ai-2027.com/about sowie Steven Adlers Bericht „A crisis '
                'simulation changed how I think about AI risk" — Rollen, '
                'Rundenstruktur, Würfel-Adjudikation.',
            'ai-2027.com/about plus Steven Adler\'s report "A crisis '
                'simulation changed how I think about AI risk" — roles, '
                'round structure, dice adjudication.',
          ),
        ),
        CodexBullet(
          LText('The Morpheus', 'The Morpheus'),
          LText(
            '„Dieses Paper untersucht den kalten AI Krieg" (YouTube, '
                '2026), deutschsprachige Einordnung des Szenarios.',
            '"Dieses Paper untersucht den kalten AI Krieg" (YouTube, '
                '2026), German-language analysis of the scenario.',
          ),
        ),
      ]),
    ],
  ),
];
