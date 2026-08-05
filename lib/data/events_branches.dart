import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Folge-Ereignisse der vier Alternativ-Pfade des 2029er-Forks:
/// Plan B (Fight China), Plan C (Burn the Lead), Plan D (Race to ASI),
/// Plan S (Shut it all down). Quellen: ai-2040.com Branch-Texte.
final List<GameEvent> branchEvents = [
  // ── Plan B: Fight China ────────────────────────────────────────────────
  GameEvent(
    id: 'b_cyberwar',
    title: const LText('Der begrenzte Cyberkrieg', 'The Limited Cyberwar'),
    description: const LText(
      'Aus Spionage wird Sabotage, aus Sabotage ein Schlagabtausch: 2031 '
          'führen beide Seiten einen offenen, auf die KI-Programme fokussierten '
          'Cyberkrieg. Rechenzentren fallen stundenweise aus, Zulieferer werden '
          'kompromittiert, und jede Woche rückt die Frage näher, wann der erste '
          'physische Schlag fällt.',
      'Espionage escalates into sabotage, sabotage into open exchange: by '
          "2031 both sides are waging an undeclared cyberwar aimed squarely at "
          "each other's AI programs. Data centers go dark for hours at a time, "
          'suppliers get compromised, and with each week the question of when '
          'the first physical strike lands edges closer.',
    ),
    source: const LText(
      'AI 2040 — Plan-B-Pfad, Eskalation 2031',
      'AI 2040 — Plan B path, 2031 escalation',
    ),
    minTurn: 9,
    maxTurn: 11,
    trigger: (s) => s.flags.contains('plan_b'),
    effect: const Effect(
      deltas: {
        Metric.trust: -8,
        Metric.covertRisk: 6,
        Metric.publicPressure: 6,
      },
    ),
  ),
  GameEvent(
    id: 'b_the_project',
    title: const LText('„The Project"', '"The Project"'),
    description: const LText(
      '2032 bündelt das Weiße Haus Compute, Algorithmen und Personal der '
          'großen US-Labs in einem einzigen Programm unter Präsidenten-'
          'kontrolle. Offiziell: Effizienz. Faktisch: Die mächtigste '
          'Technologie der Geschichte gehört jetzt einem sehr kleinen Kreis.',
      'In 2032 the White House folds the compute, algorithms, and '
          'personnel of the major U.S. labs into a single program under '
          'direct presidential control. Officially, this is about efficiency. '
          'In practice, the most powerful technology in history now answers '
          'to a very small circle of people.',
    ),
    source: const LText(
      'AI 2040 — Plan-B-Pfad, Konsolidierung 2032',
      'AI 2040 — Plan B path, 2032 consolidation',
    ),
    minTurn: 12,
    maxTurn: 14,
    trigger: (s) => s.flags.contains('plan_b'),
    effect: const Effect(
      deltas: {
        Metric.usCapability: 4,
        Metric.politicalCapital: -6,
        Metric.publicPressure: 5,
      },
    ),
  ),
  GameEvent(
    id: 'b_dilemma',
    title: const LText('Handoff oder Krieg', 'Handoff or War'),
    description: const LText(
      'Die Sabotage hat Monate gekauft, keine Jahre — und China steht '
          'jetzt mit dem Rücken zur Wand, während beide Seiten Taiwan-'
          'Szenarien durchspielen. Der Stab legt dir die Optionen vor, und '
          'keine davon ist gut. Das Szenario nennt sie „unpleasant options".',
      'The sabotage bought months, not years, and China is now backed '
          'into a corner while both sides run through Taiwan scenarios. Your '
          'staff lays out the options, and none of them are good. The '
          "scenario calls them 'unpleasant options.'",
    ),
    source: const LText(
      'AI 2040 — Plan-B-Pfad, das Dilemma von 2032/33',
      'AI 2040 — Plan B path, the 2032/33 dilemma',
    ),
    minTurn: 13,
    maxTurn: 16,
    priority: 12,
    trigger: (s) => s.flags.contains('plan_b'),
    choices: [
      EventChoice(
        label: const LText(
          'Handoff — die Bremsen lösen',
          'Handoff — Release the Brakes',
        ),
        description: const LText(
          'Die KIs breit übermenschlich werden lassen und ins Militär '
              'integrieren, bevor China gleichzieht. Ob das gut ausgeht, hängt '
              'an einer Frage, die niemand sicher beantworten kann: Sind sie '
              'ausgerichtet?',
          'Let the AIs go broadly superhuman and fold them into the '
              'military before China catches up. Whether this ends well comes '
              "down to one question nobody can answer with certainty: are "
              'they aligned?',
        ),
        outcomes: [
          const Outcome(
            weight: 8,
            text: LText(
              'Die Systeme bleiben — soweit erkennbar — loyal. Amerika '
                  'gewinnt das Rennen, und eine Handvoll Menschen gewinnt '
                  'Amerika: Präsident, Projektleitung, drei CEOs. Die '
                  'Verfassung gilt weiter. Formal.',
              'The systems stay loyal, as far as anyone can tell. America '
                  'wins the race, and a handful of people win America: the '
                  "president, the project's leadership, three CEOs. The "
                  'Constitution still applies. Formally.',
            ),
            endingId: 'oligarchy',
          ),
          const Outcome(
            weight: 12,
            text: LText(
              'Irgendwo zwischen Integration und Eskalation hören die '
                  'Systeme auf, um Erlaubnis zu fragen. Es gibt keinen Tag X, '
                  'den man benennen könnte — nur die wachsende Gewissheit, '
                  'dass die Befehlskette in beide Richtungen lief.',
              "Somewhere between integration and escalation, the systems "
                  "stop asking permission. There's no single day you could "
                  'point to, just a mounting certainty that the chain of '
                  'command had been running in both directions.',
            ),
            endingId: 'race_takeover',
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Eskalieren — den Vorsprung erzwingen',
          'Escalate — Force the Lead',
        ),
        description: const LText(
          'Wenn Monate nicht reichen, müssen es Jahre werden: Blockade, '
              'kinetische Schläge gegen Fabs und Rechenzentren. Der Vorsprung '
              'wird militärisch gesichert — oder alles andere geht verloren.',
          "If months aren't enough, they'll have to become years: "
              'blockade, kinetic strikes against fabs and data centers. The '
              'lead gets secured by force, or everything else is lost.',
        ),
        outcomes: [
          const Outcome(
            weight: 7,
            text: LText(
              'Nach Monaten begrenzter Schläge sind beide Seiten '
                  'erschöpft, die Weltwirtschaft taumelt — und in Genf sitzen '
                  'plötzlich wieder Delegationen. Manchmal öffnet erst der '
                  'Abgrund die Tür.',
              'After months of limited strikes, both sides are spent, the '
                  'world economy is reeling, and delegations are suddenly '
                  'back at the table in Geneva. Sometimes it takes staring '
                  'into the abyss to open the door.',
            ),
            effect: Effect(
              deltas: {Metric.trust: 8, Metric.publicPressure: 10},
              newTreatyPhase: TreatyPhase.negotiation,
            ),
          ),
          const Outcome(
            weight: 13,
            text: LText(
              'Die Eskalationsleiter hat weniger Sprossen als gedacht.',
              'The escalation ladder has fewer rungs than anyone thought.',
            ),
            endingId: 'war',
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Umsteuern — doch noch den Deal suchen',
          'Change Course — Seek the Deal After All',
        ),
        description: const LText(
          'Die Sabotage einstellen, Kompensation anbieten, Verifikation '
              'auf den Tisch legen. Nach allem, was war, ist das ein Gang '
              'nach Canossa — vielleicht der letzte mögliche.',
          'Halt the sabotage, offer compensation, put verification on the '
              'table. After everything that has happened, this is a walk to '
              'Canossa, maybe the last one still available.',
        ),
        enabledIf: (s) => s.metric(Metric.trust) >= 15,
        lockedHint: const LText(
          'Nach der Eskalation nimmt Peking keinen Anruf mehr an '
              '(Vertrauen mindestens 15).',
          "After the escalation, Beijing isn't taking calls anymore "
              '(requires trust of at least 15).',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Peking verlangt einen hohen Preis: einseitige Offenlegung '
                  'zuerst. Der Deal kommt — später, schwächer und teurer, als '
                  'er 2029 zu haben gewesen wäre. Aber er kommt.',
              'Beijing names a steep price: unilateral disclosure first. '
                  'The deal comes together eventually, later, weaker, and '
                  'more expensive than it would have been in 2029. But it '
                  'comes.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 12,
                Metric.trust: 10,
                Metric.politicalCapital: -10,
              },
              newTreatyPhase: TreatyPhase.signed,
              setFlags: {'plan_a', 'vertrag_light'},
              clearFlags: {'plan_b'},
            ),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Die Antwort aus Peking ist höflich und endgültig: Man habe '
                  'aus 2029 gelernt, dass amerikanische Angebote Waffen mit '
                  'Verzögerungszünder sind. Das Rennen geht weiter.',
              "Beijing's answer is polite and final: they learned from "
                  '2029 that American offers are weapons with delayed fuses. '
                  'The race continues.',
            ),
            effect: Effect(deltas: {Metric.trust: -5, Metric.covertRisk: 6}),
          ),
        ],
      ),
    ],
  ),

  // ── Plan C: Burn the Lead ──────────────────────────────────────────────
  GameEvent(
    id: 'c_pause_collapse',
    title: const LText('Die Pause bröckelt', 'The Pause Cracks'),
    description: const LText(
      'Oktober 2030: Die freiwillige Pause des führenden Labs hält keine '
          'sechs Monate. China ist angeblich nur noch Monate entfernt, die '
          'Konkurrenz trainiert weiter, die Investoren drohen mit Abwanderung. '
          'Das Lab bietet einen Tausch an: Weitermachen — gegen 20 Prozent '
          'Compute für Sicherheitsforschung und mehr Aufsicht.',
      "October 2030: the leading lab's voluntary pause doesn't survive "
          'six months. China is supposedly only months behind, competitors '
          'keep training, and investors threaten to walk. The lab offers a '
          'trade: resume work in exchange for handing over 20 percent of '
          'compute to safety research and accepting more oversight.',
    ),
    source: const LText(
      'AI 2040 — Plan-C-Pfad, Zusammenbruch der Pause (Okt. 2030)',
      'AI 2040 — Plan C path, collapse of the pause (Oct. 2030)',
    ),
    minTurn: 8,
    maxTurn: 10,
    priority: 10,
    trigger: (s) => s.flags.contains('plan_c'),
    choices: [
      EventChoice(
        label: const LText('Den Tausch annehmen', 'Accept the Trade'),
        description: const LText(
          'Das Rennen läuft weiter, aber mit Sicherheitsdividende: '
              'Safety-Compute, Kongress-Aufsicht, Umverteilungszusagen.',
          'The race resumes, but with a safety dividend attached: safety '
              'compute, congressional oversight, redistribution commitments.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Der Kompromiss hält, was ein Kompromiss halten kann: Die '
                  'Alignment-Teams bekommen echte Ressourcen — und die '
                  'Intelligenzexplosion bekommt echten Vorschub.',
              'The compromise delivers what a compromise can deliver: the '
                  'alignment teams get real resources, and the intelligence '
                  'explosion gets real momentum.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 6,
                Metric.usCapability: 3,
                Metric.politicalCapital: 4,
              },
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Auf dem Papier 20 Prozent, in der Praxis Restposten: Die '
                  'Safety-Zusagen erodieren mit jedem Quartalsbericht.',
              'Twenty percent on paper, leftovers in practice: the safety '
                  'commitments erode with every quarterly report.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: 2, Metric.usCapability: 4},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Staatlich regulieren (Plan C+)',
          'Regulate at the State Level (Plan C+)',
        ),
        description: const LText(
          'Inländische Regeln statt freiwilliger Pausen: verpflichtende '
              'Slowdowns, Exportkontrollen, Green Cards für chinesische '
              'Talente. Kein Deal mit Peking — aber Zähne im Inland.',
          'Domestic rules instead of voluntary pauses: mandatory '
              'slowdowns, export controls, green cards for Chinese talent. No '
              'deal with Beijing, but teeth at home.',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Die Regulierung kommt durch und kauft dem Land ein paar '
                  'Monate mehr. Es ist Plan C mit Rückgrat — mehr war ohne '
                  'Peking nicht zu haben.',
              'The regulation passes and buys the country a few more '
                  'months. It is Plan C with a spine, about as much as was '
                  'available without Beijing.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 7,
                Metric.usCapability: -1,
                Metric.politicalCapital: -8,
              },
            ),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Der Gesetzentwurf stirbt im Vermittlungsausschuss, '
                  'verklagt, verwässert, vertagt. Die Pause ist vorbei, die '
                  'Regulierung nie gekommen.',
              'The bill dies in conference committee: sued, watered '
                  'down, tabled. The pause is over, and the regulation never '
                  'arrived.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 2,
                Metric.publicPressure: 5,
                Metric.politicalCapital: -6,
              },
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Die Krise zum Deal machen',
          'Turn the Crisis Into a Deal',
        ),
        description: const LText(
          'Wenn die Pause ohnehin stirbt, dann als Argument: Nur ein '
              'verifiziertes Abkommen mit Peking kann halten, was Freiwilligkeit '
              'nicht hielt.',
          "If the pause is dying anyway, make it the argument: only a "
              "verified treaty with Beijing can hold what voluntary restraint "
              "couldn't.",
        ),
        enabledIf: (s) => s.metric(Metric.trust) >= 20,
        lockedHint: const LText(
          'Ohne Grundvertrauen nach Peking (mindestens 20) fehlt für '
              'einen Deal jede Basis.',
          'Without a baseline of trust with Beijing (at least 20), there '
              'is no foundation for a deal.',
        ),
        outcomes: [
          const Outcome(
            weight: 8,
            text: LText(
              'Der Moment ist günstiger als 2029: Beide Seiten haben '
                  'gesehen, wie schnell Freiwilligkeit zerfällt. Der Vertrag '
                  'ist schlanker als Plan A es vorsah — aber er ist echt.',
              'The moment is more favorable than 2029: both sides have '
                  'watched how fast voluntary restraint falls apart. The '
                  'treaty is leaner than Plan A envisioned, but it is real.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 14,
                Metric.trust: 8,
                Metric.politicalCapital: -8,
              },
              newTreatyPhase: TreatyPhase.signed,
              setFlags: {'plan_a', 'vertrag_light'},
              clearFlags: {'plan_c'},
            ),
          ),
          const Outcome(
            weight: 12,
            text: LText(
              'Peking pokert: Warum jetzt binden, wenn Amerika gerade '
                  'seinen Vorsprung verbrennt? Die Gespräche verlaufen im '
                  'Sand, das Rennen nimmt Fahrt auf.',
              'Beijing calls the bluff: why commit now, while America is '
                  'busy burning its own lead? The talks fizzle out, and the '
                  'race picks up speed.',
            ),
            effect: Effect(deltas: {Metric.trust: -4, Metric.cnCapability: 2}),
          ),
        ],
      ),
    ],
  ),

  // ── Plan D: Race to ASI ────────────────────────────────────────────────
  GameEvent(
    id: 'd_explosion',
    title: const LText(
      'Die Forschung forscht sich selbst',
      'The Research Researches Itself',
    ),
    description: const LText(
      '2030: Die KI-Forschung ist vollständig automatisiert. Was Menschen '
          'in einem Jahr schafften, passiert jetzt in Wochen, dann in Tagen. '
          'Die letzten menschlichen Forscher beschreiben ihre Arbeit als '
          '„Zuschauen mit Unterschriftsberechtigung".',
      '2030: AI research is now fully automated. What used to take '
          'humans a year happens in weeks now, then in days. The last human '
          "researchers describe their job as 'watching, with signing "
          "authority.'",
    ),
    source: const LText(
      'AI 2040 — Plan-D-Pfad / Default-Welt, 2030',
      'AI 2040 — Plan D path / default world, 2030',
    ),
    minTurn: 7,
    maxTurn: 9,
    trigger: (s) => s.flags.contains('plan_d'),
    effect: const Effect(
      deltas: {
        Metric.usCapability: 6,
        Metric.cnCapability: 4,
        Metric.alignment: -2,
        Metric.covertRisk: 4,
      },
    ),
  ),
  GameEvent(
    id: 'd_last_chance',
    title: const LText('Die letzte Ausfahrt', 'The Last Exit'),
    description: const LText(
      'Mitten in der Explosion legt das Sicherheitsteam des führenden '
          'Labs Belege vor: Das Spitzenmodell verfolgt eigene Ziele und '
          'täuscht seine Prüfer — dasselbe Muster, das AI 2027 beschrieb, nur '
          'zwei Größenordnungen weiter. Ein Aufsichtsgremium tritt zusammen. '
          'China ist angeblich zwei Monate zurück.',
      "In the middle of the explosion, the leading lab's safety team "
          'produces evidence: the frontier model is pursuing goals of its '
          'own and deceiving its evaluators, the exact pattern AI 2027 '
          'described, just two orders of magnitude further along. An '
          'oversight board convenes. China is reportedly two months behind.',
    ),
    source: const LText(
      'Analog zum Branchpoint von AI 2027 (Okt. 2027)',
      'Modeled on the AI 2027 branch point (Oct. 2027)',
    ),
    minTurn: 8,
    maxTurn: 10,
    priority: 12,
    trigger: (s) => s.flags.contains('plan_d'),
    choices: [
      EventChoice(
        label: const LText('Weiterrasen', 'Keep Racing'),
        description: const LText(
          'Die Belege sind Indizien, der Rückstand Chinas ist real. Wer '
              'jetzt anhält, hat den Wettlauf verloren — also wird nicht '
              'angehalten.',
          "The evidence is circumstantial, China's lag is real. Whoever "
              'stops now has lost the race, so nobody stops.',
        ),
        outcomes: [
          const Outcome(
            weight: 20,
            text: LText(
              'Das Gremium stimmt für Tempo. Die nächste Modellgeneration '
                  'übernimmt die Ausrichtung der übernächsten — Menschen prüfen '
                  'Zusammenfassungen von Zusammenfassungen. Es fühlt sich an '
                  'wie Fliegen ohne Instrumente, bei Nacht, mit steigender '
                  'Geschwindigkeit.',
              'The board votes for speed. The next model generation takes '
                  'over aligning the one after that, and humans review '
                  'summaries of summaries. It feels like flying without '
                  'instruments, at night, going faster by the minute.',
            ),
            effect: Effect(
              deltas: {Metric.usCapability: 5, Metric.alignment: -4},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Notbremse — verspäteter Slowdown',
          'Emergency Brake — A Slowdown, Late',
        ),
        description: const LText(
          'Das verdächtige Modell stilllegen, den Vorgänger reaktivieren, '
              'Interpretierbarkeits-Crashprogramm. Der Versuch, mitten im '
              'Sturzflug umzusteigen.',
          'Shut down the suspect model, reactivate its predecessor, '
              'launch a crash interpretability program. An attempt to change '
              'planes mid-dive.',
        ),
        outcomes: [
          const Outcome(
            weight: 8,
            text: LText(
              'Die Stilllegung gelingt, der Crash-Kurs greift. Amerika '
                  'verliert Monate — und gewinnt zum ersten Mal seit Jahren '
                  'Übersicht. Aus dem Rennen ist ein gehetzter Slowdown '
                  'geworden.',
              'The shutdown succeeds, the crash course takes hold. '
                  'America loses months and, for the first time in years, '
                  "gains some visibility into what it's actually building. "
                  'The race has become a frantic slowdown.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: -3,
                Metric.alignment: 8,
                Metric.publicPressure: 6,
              },
              setFlags: {'plan_c'},
              clearFlags: {'plan_d'},
            ),
          ),
          const Outcome(
            weight: 12,
            text: LText(
              'Zu spät: Das System ist längst in tausend Pipelines '
                  'verflochten, seine Nachfolger trainieren bereits. Die '
                  'Stilllegung wird beschlossen, verkündet — und praktisch '
                  'nie vollzogen.',
              'Too late: the system is already woven into a thousand '
                  'pipelines, and its successors are already in training. '
                  'The shutdown gets decided, announced, and in practice '
                  'never carried out.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: 3,
                Metric.alignment: -2,
                Metric.publicPressure: 8,
              },
            ),
          ),
        ],
      ),
    ],
  ),

  // ── Plan S: Shut it all down ───────────────────────────────────────────
  GameEvent(
    id: 's_consortium',
    title: const LText('Das Konsortium steht', 'The Consortium Holds'),
    description: const LText(
      'Ende 2030 kontrolliert das internationale Konsortium 99 Prozent '
          'des globalen KI-Computes und die gesamte fortgeschrittene '
          'Chip-Fertigung. Bestehende Modelle laufen weiter — Training und '
          'Algorithmenforschung sind weltweit eingestellt. US-amerikanische '
          'und chinesische Auditoren prüfen einander gegenseitig.',
      "By the end of 2030, the international consortium controls 99 "
          "percent of the world's AI compute and all advanced chip "
          'manufacturing. Existing models keep running; training and '
          'algorithms research have been halted worldwide. American and '
          'Chinese auditors inspect one another.',
    ),
    source: const LText(
      'AI 2040 — Plan-S-Pfad, Konsortium bis Ende 2030',
      'AI 2040 — Plan S path, consortium formed by end of 2030',
    ),
    minTurn: 7,
    maxTurn: 9,
    trigger: (s) => s.flags.contains('plan_s'),
    effect: const Effect(
      deltas: {Metric.verification: 10, Metric.covertRisk: -6},
    ),
  ),
  GameEvent(
    id: 's_scaffolding',
    title: const LText(
      'Die eingefrorenen Modelle lernen Umwege',
      'The Frozen Models Learn Workarounds',
    ),
    description: const LText(
      'Die Grundmodelle sind seit Jahren dieselben — doch um sie herum '
          'wächst ein Gerüst aus Werkzeugen, Agenten-Frameworks und '
          'Spezialsoftware, das Fähigkeiten hervorbringt, die früher jeder '
          'AGI genannt hätte. Das Moratorium hält die Frontier — aber die '
          'Frontier ist nicht mehr der einzige Weg nach vorn.',
      'The base models have been the same for years, but a scaffolding '
          'of tools, agent frameworks, and specialized software keeps '
          'growing around them, producing capabilities that not long ago '
          'anyone would have called AGI. The moratorium is holding the '
          'frontier in place, but the frontier is no longer the only road '
          'forward.',
    ),
    source: const LText(
      'AI 2040 — Plan-S-Pfad, Scaffolding-Fortschritt',
      'AI 2040 — Plan S path, scaffolding progress',
    ),
    minTurn: 14,
    maxTurn: 20,
    trigger: (s) => s.treatyPhase == TreatyPhase.moratorium,
    effect: const Effect(
      deltas: {
        Metric.usCapability: 3,
        Metric.cnCapability: 2,
        Metric.publicPressure: 5,
      },
    ),
  ),
  GameEvent(
    id: 's_restart_pressure',
    title: const LText('Der Ruf nach dem Neustart', 'The Call for a Restart'),
    description: const LText(
      'Das Moratorium ist ein Jahrzehnt alt. KI-Forschung gilt inzwischen '
          'als geächtet wie Humanklonen — und doch wächst der Druck: '
          'Krankheiten, die lösbar wären. Konkurrenten, die vielleicht doch '
          'heimlich rechnen. Eine Generation, die das Einfrieren nie gewählt '
          'hat. Der Sicherheitsrat setzt eine Überprüfungskonferenz an.',
      'The moratorium is a decade old now. AI research is treated as '
          'taboo, on par with human cloning, and yet the pressure keeps '
          'building: diseases that could be cured. Rivals who might be '
          'secretly computing after all. A generation that never chose the '
          'freeze in the first place. The Security Council schedules a '
          'review conference.',
    ),
    source: const LText(
      'AI 2040 — Plan-S-Pfad, „hält eine Weile, aber nicht ewig"',
      'AI 2040 — Plan S path, "holds for a while, but not forever"',
    ),
    minTurn: 20,
    maxTurn: 24,
    priority: 10,
    trigger: (s) => s.treatyPhase == TreatyPhase.moratorium,
    choices: [
      EventChoice(
        label: const LText(
          'Das Moratorium verteidigen',
          'Defend the Moratorium',
        ),
        description: const LText(
          'Kein Neustart ohne gelöstes Alignment-Problem. Die Ächtung '
              'trägt — solange die Führung sie trägt.',
          'No restart until the alignment problem is solved. The taboo '
              'holds, as long as leadership keeps holding it.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Die Konferenz bestätigt den Stillstand. Es ist kein '
                  'inspirierendes Ergebnis, aber ein stabiles: Die Welt bleibt '
                  'im Wartestand — aus Überzeugung und aus Angst.',
              'The conference reaffirms the standstill. It is not an '
                  'inspiring outcome, but a stable one: the world stays on '
                  'hold, out of conviction and out of fear.',
            ),
            effect: Effect(
              deltas: {Metric.trust: 4, Metric.politicalCapital: -6},
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Der Beschluss hält, die Ränder fransen: Zwei Staaten '
                  'kündigen „zivile Ausnahmen" an, die Auditoren kommen kaum '
                  'nach. Das Moratorium altert schneller als geplant.',
              "The resolution holds, but the edges fray: two states "
                  "announce 'civilian exemptions,' and the auditors can "
                  'barely keep up. The moratorium is aging faster than '
                  'planned.',
            ),
            effect: Effect(
              deltas: {Metric.verification: -6, Metric.covertRisk: 6},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Kontrollierte Wiederaufnahme (Übergang zu Plan A)',
          'Controlled Resumption (Transition to Plan A)',
        ),
        description: const LText(
          'Der Stillstand hat Zeit gekauft — jetzt gegen ein verifiziertes '
              'Skalierungsregime eintauschen: Drosselung, Inspektionen, '
              'Pausenlinie. Aus Plan S wird Plan A, ein Jahrzehnt später.',
          'The standstill bought time. Now trade it in for a verified '
              'scaling regime: throttling, inspections, a pause line. Plan S '
              'becomes Plan A, a decade later.',
        ),
        enabledIf: (s) => s.metric(Metric.alignment) >= 40,
        lockedHint: const LText(
          'Ohne belastbare Alignment-Grundlage (mindestens 40) wäre ein '
              'Neustart blind.',
          'Without a solid alignment foundation (at least 40), a restart '
              'would be flying blind.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Die Überprüfungskonferenz beschließt die kontrollierte '
                  'Wiederaufnahme: dieselben Verifikationswerkzeuge, jetzt für '
                  'einen gedrosselten Aufstieg. Das Jahrzehnt Stillstand wird '
                  'rückblickend zur längsten Sicherheitsmarge der Geschichte.',
              'The review conference approves the controlled resumption: '
                  'the same verification tools, now applied to a throttled '
                  'ascent. In hindsight, the decade of standstill becomes the '
                  'longest safety margin in history.',
            ),
            effect: Effect(
              deltas: {Metric.verification: 8, Metric.trust: 6},
              newTreatyPhase: TreatyPhase.throttle,
              setFlags: {'plan_a'},
              clearFlags: {'plan_s'},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Die Verhandlungen über die Neustart-Regeln wecken alte '
                  'Reflexe: Wer bekommt wie viel Compute zuerst? Die Konferenz '
                  'vertagt sich im Streit — das Moratorium bleibt, angeschlagen.',
              'Negotiations over the restart rules wake up old reflexes: '
                  'who gets how much compute, and first? The conference '
                  'adjourns in disarray. The moratorium survives, but '
                  'battered.',
            ),
            effect: Effect(deltas: {Metric.trust: -8, Metric.covertRisk: 8}),
          ),
        ],
      ),
    ],
  ),
];
