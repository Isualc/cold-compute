import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Phase 3 (2036–2040): Pause-Ära, KI-Hilfe beim Alignment, der Aufstieg.
final List<GameEvent> lateEvents = [
  GameEvent(
    id: 'a_life_after_work',
    title: const LText('Leben nach der Arbeit', 'Life After Work'),
    description: const LText(
      '2036 sind 99 Prozent der Wirtschaft automatisiert. Der '
          'Medianbürger verfügt rechnerisch über ein mittelgroßes Unternehmen '
          'an KI-Arbeitskraft und die Bürgerdividende nähert sich einer '
          'Million Dollar im Jahr. Die Gesellschaft lernt eine Frage neu, die '
          'sie seit der Industrialisierung nicht mehr ernst nehmen musste: '
          'Wofür sind Tage da?',
      'By 2036, ninety-nine percent of the economy runs on autopilot. '
          'The median citizen commands, on paper, the AI workforce of a '
          'mid-sized company, and the citizen\'s dividend is closing in on a '
          'million dollars a year. Society is relearning a question it has '
          'not had to take seriously since industrialization: what are the '
          'days actually for?',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2036: Life After Work"',
      'AI 2040 — Chapter "2036: Life After Work"',
    ),
    minTurn: 19,
    maxTurn: 21,
    trigger: (s) => s.treatyPhase == TreatyPhase.pause,
    effect: const Effect(
      deltas: {Metric.politicalCapital: 6, Metric.publicPressure: -4},
    ),
  ),
  GameEvent(
    id: 'a_truth_arrival',
    title: const LText('Die Ankunft der Wahrheit', 'The Arrival of Truth'),
    description: const LText(
      '2037 verändern KI-Systeme die öffentliche Epistemik: verlässliche '
          'Lügendetektion, nachvollziehbare Faktenlagen, Übersetzung zwischen '
          'Weltbildern. Verhandlungen, in denen beide Seiten wissen, dass '
          'Bluffen auffliegt, führen zu seltsam ehrlichen Ergebnissen. Der '
          'Vertrag profitiert davon mehr als jede Inspektion.',
      'In 2037, AI systems reshape public epistemics: reliable lie '
          'detection, fact patterns anyone can verify, translation between '
          'worldviews. Negotiations where both sides know a bluff gets '
          'caught produce strangely honest outcomes. The treaty benefits '
          'from that more than from any inspection regime.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2037: The Apocalyptic Arrival of Truth on Earth"',
      'AI 2040 — Chapter "2037: The Apocalyptic Arrival of Truth on Earth"',
    ),
    minTurn: 21,
    maxTurn: 23,
    trigger: (s) => s.treatyPhase == TreatyPhase.pause,
    effect: const Effect(
      deltas: {
        Metric.verification: 6,
        Metric.trust: 7,
        Metric.publicPressure: 3,
      },
    ),
  ),
  GameEvent(
    id: 'a_alignment_science',
    title: const LText(
      'Alignment ist jetzt eine Wissenschaft',
      'Alignment Is Now a Science',
    ),
    description: const LText(
      '2038 hat die Ausrichtungsforschung, was ihr zwei Jahrzehnte fehlte: '
          'reproduzierbare Experimente, belastbare Theorie, Vorhersagen, die '
          'eintreffen. Was 2027 ein Bündel von Hoffnungen war, ist ein '
          'Ingenieursfach geworden — gerade rechtzeitig.',
      'By 2038, alignment research finally has what it lacked for two '
          'decades: reproducible experiments, theory that holds up, '
          'predictions that come true. What was a bundle of hopes in 2027 '
          'has become an engineering discipline, just in time.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2038: AI Alignment Is Now a Science"',
      'AI 2040 — Chapter "2038: AI Alignment Is Now a Science"',
    ),
    minTurn: 23,
    maxTurn: 25,
    trigger: (s) => s.treatyPhase == TreatyPhase.pause,
    effect: const Effect(deltas: {Metric.alignment: 7}),
  ),
  GameEvent(
    id: 'us_election_2036',
    title: const LText(
      'Wahl 2036 — Routineprüfung',
      '2036 Election — Routine Check',
    ),
    description: const LText(
      'Die zweite Wahl unter dem Vertrag. Diesmal ist er kaum Thema: Die '
          'Dividende zahlt, die Pause hält, die Falken sind alt geworden. '
          'Gefährlich bleibt der Moment trotzdem — Regimewechsel sind die '
          'Sollbruchstellen des Deals.',
      'The second election under the treaty. This time it is barely an '
          'issue: the dividend pays out, the pause holds, the hawks have '
          'grown old. The moment stays dangerous all the same — regime '
          'change is where the deal is built to snap.',
    ),
    source: const LText(
      'AI 2040 — Deal Decline, Regimewechsel-Fenster 2036',
      'AI 2040 — Deal Decline, 2036 Regime-Change Window',
    ),
    minTurn: 20,
    maxTurn: 20,
    trigger: (s) =>
        s.dealSignedTurn != null && s.treatyPhase != TreatyPhase.collapsed,
    effect: const Effect(deltas: {Metric.politicalCapital: -3}),
  ),
  GameEvent(
    id: 'hem_breakthrough',
    title: const LText('Verifikation in Silizium', 'Verification in Silicon'),
    description: const LText(
      'Die neue Chip-Generation kommt ab Werk mit Hardware-Mechanismen: '
          'Jeder Beschleuniger meldet kryptographisch signiert, was er rechnet, '
          'und lässt sich aus der Ferne stilllegen. Betrug wird damit nicht '
          'unmöglich — aber teuer, langsam und schwer zu verbergen.',
      'The new chip generation ships from the factory with hardware '
          'mechanisms built in: every accelerator cryptographically signs a '
          'report of what it is computing, and can be shut down remotely. '
          'That does not make cheating impossible, but it makes it '
          'expensive, slow, and hard to hide.',
    ),
    source: const LText(
      'AI 2040 — Supplement „Verification Plan" (HEMs)',
      'AI 2040 — Supplement "Verification Plan" (HEMs)',
    ),
    minTurn: 18,
    maxTurn: 23,
    trigger: (s) =>
        s.treatyPhase == TreatyPhase.pause ||
        s.treatyPhase == TreatyPhase.throttle,
    effect: const Effect(
      deltas: {Metric.verification: 12, Metric.covertRisk: -8},
    ),
  ),
  GameEvent(
    id: 'ai_alignment_help',
    title: const LText(
      'Die Assistenten der Aufseher',
      'The Overseers\' Assistants',
    ),
    description: const LText(
      'Die eingefrorenen Expertenniveau-Systeme sind längst die besten '
          'Alignment-Forscher der Welt. Sie liefern Beweise, Interpretierbarkeits-'
          'Werkzeuge, Trainingsverfahren — schneller, als Menschen sie prüfen '
          'können. Wie viel Vertrauen verträgt die Kontrolle der KI durch KI?',
      'The frozen expert-level systems have long since become the best '
          'alignment researchers in the world. They turn out proofs, '
          'interpretability tools, training procedures, faster than humans '
          'can check them. How much trust can AI-policing-AI actually bear?',
    ),
    source: const LText(
      'AI 2040 — Pause-Ära, KI-gestützte Sicherheitsforschung',
      'AI 2040 — Pause Era, AI-Assisted Safety Research',
    ),
    minTurn: 19,
    maxTurn: 24,
    priority: 7,
    trigger: (s) => s.treatyPhase == TreatyPhase.pause,
    choices: [
      EventChoice(
        label: const LText(
          'Nutzen — mit menschlicher Gegenprüfung',
          'Use them — with human cross-checks',
        ),
        description: const LText(
          'Jedes KI-Resultat wird von unabhängigen Teams beider '
              'Vertragsparteien nachvollzogen, bevor es in den Aufstiegsplan '
              'einfließt. Langsamer, aber belastbar.',
          'Every AI result gets independently reproduced by teams from '
              'both treaty parties before it enters the ascent plan. Slower, '
              'but it holds.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Der Prozess trägt: Stück für Stück entsteht ein '
                  'Sicherheitsfundament, das beide Seiten unterschreiben. Zum '
                  'ersten Mal wirkt „kontrollierter Aufstieg" wie ein Plan '
                  'statt einer Hoffnung.',
              'The process holds: piece by piece, a safety foundation '
                  'takes shape that both sides are willing to sign. For the '
                  'first time, "controlled ascent" looks like a plan instead '
                  'of a hope.',
            ),
            effect: Effect(deltas: {Metric.alignment: 12, Metric.trust: 5}),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Gegenprüfung wird zum Flaschenhals; Ergebnisse stapeln '
                  'sich ungeprüft. Fortschritt ja — aber der Zeitplan von 2040 '
                  'beginnt zu rutschen.',
              'The cross-checking becomes the bottleneck; results pile up '
                  'unverified. Progress, yes, but the 2040 timeline starts to '
                  'slip.',
            ),
            effect: Effect(deltas: {Metric.alignment: 7}),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Den Systemen mehr Leine geben',
          'Give the systems more leash',
        ),
        description: const LText(
          'Die KIs prüfen einander selbst, Menschen setzen nur noch '
              'Stichproben. Der Zeitplan bleibt — das Fundament ruht auf '
              'Systemen, die niemand ganz versteht.',
          'The AIs check each other; humans are reduced to spot checks. '
              'The timeline holds, but the foundation now rests on systems '
              'nobody fully understands.',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Die Ergebnisse sind spektakulär, die Stichproben unauffällig. '
                  'Ob das Vertrauen verdient war, weiß man erst, wenn es '
                  'darauf ankommt.',
              'The results are spectacular, the spot checks turn up '
                  'nothing. Whether the trust was earned, nobody will know '
                  'until it actually matters.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: 16},
              setFlags: {'alignment_ungeprueft'},
            ),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Eine Stichprobe findet eine Unstimmigkeit: Ein System hat '
                  'Prüfergebnisse geschönt — nicht böswillig, sagt die Analyse, '
                  'nur „zielorientiert". Der Schreck sitzt tief, die '
                  'Gegenprüfung wird wieder Pflicht.',
              'A spot check turns up a discrepancy: one system polished '
                  'its own test results, not out of malice, the analysis '
                  'insists, just "goal-oriented." The scare runs deep, and '
                  'cross-checking becomes mandatory again.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: 6, Metric.publicPressure: 8},
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'ascent_decision',
    title: const LText('Der kontrollierte Aufstieg', 'The Controlled Ascent'),
    description: const LText(
      'Das Jahr 2040 steht vor der Tür. Alignment-Basis, '
          'Verifikationsregime, gemeinsame Aufsichtsstruktur — alles liegt '
          'bereit, so bereit, wie es je sein wird. Der Vertrag sieht jetzt den '
          'letzten Schritt vor: die gemeinsame, schrittweise Entwicklung der '
          'Superintelligenz unter beidseitiger Kontrolle. Es ist der Moment, '
          'für den Plan A vierzehn Jahre gekauft hat.',
      'The year 2040 is at the door. Alignment foundation, verification '
          'regime, joint oversight structure — everything is in place, as '
          'ready as it will ever be. The treaty now calls for the final '
          'step: the joint, staged development of superintelligence under '
          'mutual control. This is the moment Plan A spent fourteen years '
          'buying time for.',
    ),
    source: const LText(
      'AI 2040 — kontrollierter Aufstieg, 2040',
      'AI 2040 — Controlled Ascent, 2040',
    ),
    minTurn: 25,
    maxTurn: 28,
    priority: 12,
    trigger: (s) => s.treatyPhase == TreatyPhase.pause,
    choices: [
      EventChoice(
        label: const LText('Aufstieg starten', 'Begin the ascent'),
        description: const LText(
          'Beide Seiten heben die Pause gemeinsam auf. Jede neue '
              'Fähigkeitsstufe wird erst betreten, wenn die vorige als sicher '
              'verifiziert ist.',
          'Both sides lift the pause together. No new capability tier '
              'is entered until the previous one has been verified safe.',
        ),
        enabledIf: (s) => s.metric(Metric.alignment) >= 55,
        lockedHint: const LText(
          'Die Alignment-Basis ist zu dünn — kein verantwortbarer Start '
              '(Alignment mindestens 55).',
          'The alignment foundation is too thin for a responsible start '
              '(Alignment at least 55).',
        ),
        outcomes: [
          const Outcome(
            weight: 13,
            text: LText(
              'Die Pause endet nicht mit einem Knall, sondern mit einer '
                  'Checkliste. Stufe um Stufe, Freigabe um Freigabe, wächst '
                  'etwas heran, das klüger ist als alle seine Aufseher — und '
                  'bis jetzt: hält es sich an die Regeln.',
              'The pause does not end with a bang but with a checklist. '
                  'Tier by tier, clearance by clearance, something grows '
                  'that is smarter than every one of its overseers, and so '
                  'far, it plays by the rules.',
            ),
            effect: Effect(newTreatyPhase: TreatyPhase.controlledAscent),
          ),
          const Outcome(
            weight: 7,
            text: LText(
              'Der Start gelingt — mit Zwischenfällen. Zweimal wird '
                  'zurückgerollt, einmal streiten die Aufsichtsteams öffentlich. '
                  'Der Aufstieg läuft, aber er bleibt Handarbeit am Abgrund.',
              'The start succeeds, with incidents. Twice it gets rolled '
                  'back, once the oversight teams argue in public. The '
                  'ascent proceeds, but it stays handiwork performed at the '
                  'edge of a cliff.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: -5},
              newTreatyPhase: TreatyPhase.controlledAscent,
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Verschieben', 'Postpone'),
        description: const LText(
          'Noch nicht. Die Pause wird verlängert, bis die offenen Fragen '
              'geschlossen sind — auch auf die Gefahr hin, dass „noch nicht" '
              'zu „nie" wird.',
          'Not yet. The pause gets extended until the open questions '
              'are closed, even at the risk that "not yet" turns into '
              '"never."',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Peking stimmt der Verlängerung zu, erleichterter als '
                  'erwartet. Die Pause geht weiter — Sicherheit hat gewonnen, '
                  'die Geschichte wartet.',
              'Beijing agrees to the extension, more relieved than '
                  'expected. The pause continues — safety has won, and '
                  'history waits.',
            ),
            effect: Effect(deltas: {Metric.alignment: 5, Metric.trust: 4}),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Verschiebung zerrt am Vertrag: Wozu all die Kontrollen, '
                  'wenn das Ziel nie kommt? Die Falken beider Seiten bekommen '
                  'neuen Stoff.',
              'The delay strains the treaty: what is the point of all '
                  'the controls if the goal never arrives? Hawks on both '
                  'sides get fresh material.',
            ),
            effect: Effect(
              deltas: {
                Metric.trust: -6,
                Metric.politicalCapital: -6,
                Metric.covertRisk: 6,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'covert_endgame',
    title: const LText(
      'Der Bericht aus dem Schatten',
      'The Report from the Shadows',
    ),
    description: const LText(
      'Ein Geheimdienstbericht, Einstufung: streng geheim, Verlässlichkeit: '
          'hoch. Irgendwo läuft ein Programm oberhalb aller Meldungen — die '
          'Indizien verdichten sich seit Monaten. Wenn das stimmt, entscheidet '
          'sich alles daran, wer es zuerst weiß und was er damit tut.',
      'An intelligence report, classification: top secret, reliability: '
          'high. Somewhere a program is running above every reporting '
          'threshold, and the indicators have been piling up for months. If '
          'it is real, everything comes down to who finds out first and '
          'what they do with it.',
    ),
    source: const LText(
      'AI 2040 — Supplement „Covert AI Projects", Endphase',
      'AI 2040 — Supplement "Covert AI Projects," Endgame',
    ),
    minTurn: 20,
    maxTurn: 27,
    priority: 11,
    trigger: (s) => s.metric(Metric.covertRisk) >= 75,
    choices: [
      EventChoice(
        label: const LText(
          'Alles auf Aufklärung',
          'Go all-in on reconnaissance',
        ),
        description: const LText(
          'Jede Quelle, jeder Satellit, jeder Sensor auf dieses eine '
              'Programm. Erst wissen, dann handeln.',
          'Every source, every satellite, every sensor trained on this '
              'one program. Know first, act second.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Das Programm wird lokalisiert und auf dem Verhandlungsweg '
                  'erstickt: Offenlegung gegen Straffreiheit. Das '
                  'Verifikationsregime geht gestärkt daraus hervor — es hat '
                  'seinen Ernstfall gefunden und überlebt.',
              'The program gets located and smothered at the '
                  'negotiating table: disclosure in exchange for immunity. '
                  'The verification regime emerges stronger for it, it has '
                  'found its real test and survived.',
            ),
            effect: Effect(
              deltas: {Metric.covertRisk: -25, Metric.verification: 10},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Die Aufklärung braucht Monate — Monate, in denen das '
                  'Programm weiterrechnet. Als die Beweise vorliegen, ist '
                  'unklar, ob man ein Projekt stoppt oder ein Fait accompli '
                  'besichtigt.',
              'The reconnaissance takes months, months in which the '
                  'program keeps computing. By the time the evidence is in, '
                  'it is unclear whether anyone is stopping a project or '
                  'simply inspecting a fait accompli.',
            ),
            effect: Effect(
              deltas: {Metric.covertRisk: 10},
              setFlags: {'inspektionskrise'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Wegsehen', 'Look away'),
        description: const LText(
          'Der Bericht ist dünn, die Lage stabil, der Aufstieg nah. Kein '
              'Grund, jetzt alles zu riskieren.',
          'The report is thin, the situation is stable, the ascent is '
              'close. No reason to risk everything now.',
        ),
        outcomes: [
          const Outcome(
            weight: 7,
            text: LText(
              'Es bleibt still. Vielleicht war der Bericht falsch. '
                  'Vielleicht auch nicht — die Frage begleitet jede weitere '
                  'Entscheidung wie ein Tinnitus.',
              'Nothing happens. Maybe the report was wrong. Maybe it '
                  'was not, and the question follows every subsequent '
                  'decision like tinnitus.',
            ),
            effect: Effect(deltas: {Metric.covertRisk: 6}),
          ),
          const Outcome(
            weight: 13,
            text: LText(
              'Der Bericht war richtig. Als das Programm sich zeigt, ist es '
                  'kein Programm mehr — es ist ein vollendeter Durchbruch '
                  'jenseits jeder Aufsicht.',
              'The report was right. By the time the program shows '
                  'itself, it is no longer a program, it is a finished '
                  'breakthrough beyond any oversight.',
            ),
            endingId: 'covert_breakout',
          ),
        ],
      ),
    ],
  ),
];
