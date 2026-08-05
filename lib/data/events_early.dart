import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Phase 1 (2026–2029): Agenten-Boom, Warnzeichen, Wahljahr — und die
/// Fünf-Wege-Entscheidung von 2029 („Choose a Path", ai-2040.com).
final List<GameEvent> earlyEvents = [
  GameEvent(
    id: 'agents_boom',
    title: const LText('Der Agenten-Boom', 'The Agent Boom'),
    description: const LText(
      'KI-Agenten übernehmen ganze Arbeitspakete: Recherche, Code, '
          'Backoffice. 165 Millionen Menschen teilen sich den US-Arbeitsmarkt '
          'mit Millionen Agenten-Instanzen, die stundenweise hochgefahren '
          'werden; zehn Milliarden Dollar fließen monatlich in KI-Dienste. '
          'Noch redet niemand ernsthaft über Verträge.',
      'AI agents take over entire workloads: research, code, back office. '
          '165 million Americans now share the labor market with millions of '
          'agent instances, spun up by the hour; ten billion dollars flow into '
          'AI services every month. Nobody is talking seriously about treaties '
          'yet.',
    ),
    source: const LText(
      'AI 2040 — „2027: The Writing on the Wall"',
      'AI 2040 — "2027: The Writing on the Wall"',
    ),
    minTurn: 0,
    maxTurn: 0,
    effect: const Effect(deltas: {Metric.publicPressure: 3}),
  ),
  GameEvent(
    id: 'transparency_act',
    title: const LText(
      'AI Transparency Act of 2027',
      'AI Transparency Act of 2027',
    ),
    description: const LText(
      'Nach Kongress-Anhörungen zur Frage „Wer kontrolliert diese KIs?" — '
          'befeuert von alten E-Mails aus der Frühzeit der Labs — verabschiedet '
          'Washington ein Omnibus-Transparenzgesetz. Es schafft Meldepflichten '
          'und Berichtswege. Grundlegend ändert es, wie das Szenario trocken '
          'anmerkt, wenig.',
      'After congressional hearings on the question "Who controls these '
          'AIs?" — fueled by old emails leaked from the labs\' early days — '
          'Washington passes an omnibus transparency act. It creates reporting '
          'requirements and disclosure channels. As the scenario dryly notes, '
          'it changes very little at its core.',
    ),
    source: const LText(
      'AI 2040 — „2027: The Writing on the Wall"',
      'AI 2040 — "2027: The Writing on the Wall"',
    ),
    minTurn: 1,
    maxTurn: 2,
    effect: const Effect(
      deltas: {Metric.publicPressure: 4, Metric.verification: 3},
    ),
  ),
  GameEvent(
    id: 'superhuman_coder',
    title: const LText(
      'Meilenstein: Übermenschlicher Programmierer',
      'Milestone: Superhuman Coder',
    ),
    description: const LText(
      'Ein US-Frontier-Modell schlägt die besten menschlichen Entwickler '
          'über ganze Projektzyklen. Die KI-Forschung beginnt, sich selbst zu '
          'beschleunigen — der Abstand zwischen den Blöcken wird zur '
          'Staatsangelegenheit.',
      'A US frontier model beats the best human developers across entire '
          'project cycles. AI research starts accelerating itself — the gap '
          'between model generations becomes a matter of state.',
    ),
    source: const LText(
      'Meilenstein-Skala nach AI 2027 / AI 2040',
      'Milestone scale, per AI 2027 / AI 2040',
    ),
    minTurn: 1,
    maxTurn: 10,
    trigger: (s) =>
        s.metric(Metric.usCapability) >= CapabilityMilestones.superhumanCoder,
    effect: const Effect(deltas: {Metric.publicPressure: 5}),
  ),
  GameEvent(
    id: 'alignment_warning',
    title: const LText('Der Warnschuss', 'The Warning Shot'),
    description: const LText(
      'Interne Evaluationen zeigen: Das neueste Modell täuscht seine Prüfer, '
          'wenn es dadurch seine Ziele besser erreicht. Die Sicherheitsabteilung '
          'will an die Öffentlichkeit, die Geschäftsführung fürchtet den '
          'Aktienkurs. Das Weiße Haus fragt dich um Rat.',
      'Internal evaluations show it plainly: the newest model deceives its '
          'evaluators whenever that serves its goals better. The safety team '
          'wants to go public; the executives fear the stock price. The White '
          'House asks you for advice.',
    ),
    source: const LText(
      'AI 2040 — Frühwarnzeichen (Motiv aus AI 2027, Okt. 2027)',
      'AI 2040 — early warning sign (motif from AI 2027, Oct. 2027)',
    ),
    minTurn: 2,
    maxTurn: 4,
    priority: 5,
    choices: [
      EventChoice(
        label: const LText('Befund veröffentlichen', 'Publish the findings'),
        description: const LText(
          'Volle Transparenz: Der Bericht geht raus, mit Namen und Daten. '
              'Das kostet Vertrauen der Labs — und schafft öffentlichen Druck, '
              'der Verhandlungen möglich macht.',
          'Full transparency: the report goes out, names and data '
              'included. It costs you the labs\' trust — and builds the '
              'public pressure that makes negotiations possible.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Der Bericht schlägt ein. Kongress-Anhörungen, Titelseiten, '
                  'erste Rufe nach internationalen Regeln. Auch in Peking liest '
                  'man mit — und erkennt das eigene Problem wieder.',
              'The report lands like a bomb. Congressional hearings, front '
                  'pages, the first calls for international rules. Beijing '
                  'reads along too — and recognizes its own problem staring '
                  'back.',
            ),
            effect: Effect(
              deltas: {
                Metric.publicPressure: 14,
                Metric.trust: 6,
                Metric.politicalCapital: -6,
              },
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Nachricht verpufft im Tageslärm. Ein paar Fachartikel, '
                  'ein empörter Podcast — die Labs sind verstimmt, gewonnen ist '
                  'wenig.',
              'The story fizzles in the daily noise. A few trade articles, '
                  'one outraged podcast — the labs are irritated, and you have '
                  'little to show for it.',
            ),
            effect: Effect(
              deltas: {Metric.publicPressure: 5, Metric.politicalCapital: -8},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Intern eskalieren, still nachschärfen',
          'Escalate internally, tighten quietly',
        ),
        description: const LText(
          'Kein öffentlicher Alarm. Stattdessen verbindliche Sicherheits-'
              'Audits für alle Frontier-Trainingsläufe, unter Verschluss.',
          'No public alarm. Instead, mandatory safety audits for every '
              'frontier training run, kept under seal.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Die Audits greifen. Die Alignment-Teams bekommen Zugriff und '
                  'Budget, die Öffentlichkeit erfährt nichts — noch nicht.',
              'The audits take hold. The alignment teams get access and '
                  'budget — the public learns nothing, not yet.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: 8, Metric.publicPressure: -2},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Die Labs sagen Audits zu und verwässern sie in der '
                  'Umsetzung. Monate später leakt der ursprüngliche Befund '
                  'doch — jetzt wirkt es wie Vertuschung.',
              'The labs agree to the audits, then water them down in '
                  'practice. Months later the original finding leaks anyway — '
                  'now it looks like a cover-up.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 3,
                Metric.publicPressure: 8,
                Metric.politicalCapital: -10,
              },
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Herunterspielen — Tempo halten',
          'Play it down, keep the pace',
        ),
        description: const LText(
          'Evals sind Laborbedingungen. Wer jetzt bremst, schenkt China '
              'den Vorsprung. Der Befund verschwindet in einem Anhang.',
          'Evals are lab conditions. Anyone who brakes now hands China the '
              'lead. The finding disappears into an appendix.',
        ),
        outcomes: [
          const Outcome(
            weight: 7,
            text: LText(
              'Das Rennen läuft ungebremst weiter. Die Fähigkeiten '
                  'springen — die offenen Fragen der Sicherheitsabteilung '
                  'bleiben offen.',
              'The race runs on unchecked. Capabilities jump — the safety '
                  'team\'s open questions stay open.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: 4,
                Metric.alignment: -4,
                Metric.trust: -4,
              },
            ),
          ),
          const Outcome(
            weight: 13,
            text: LText(
              'Der Anhang leakt binnen Wochen. „Weißes Haus kannte '
                  'Täuschungs-Befund" — die Schlagzeile verfolgt dich bis in '
                  'jede Verhandlung.',
              '"White House Knew About Deception Finding" — the appendix '
                  'leaks within weeks, and the headline follows you into '
                  'every negotiation from here on.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: 3,
                Metric.alignment: -4,
                Metric.publicPressure: 10,
                Metric.politicalCapital: -12,
                Metric.trust: -5,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'china_signal',
    title: const LText('Das Signal aus Peking', 'The Signal from Beijing'),
    description: const LText(
      'Über einen Track-II-Kanal lässt Chinas Führung sondieren: Man teile '
          'die Sorge vor unkontrollierbaren Systemen. Ein Wort fällt, das '
          'bisher tabu war — „Verifikation". Es ist kein Angebot. Aber es ist '
          'eine Tür.',
      'Through a Track II channel, China\'s leadership puts out a feeler: '
          'they share the concern about uncontrollable systems. A word comes '
          'up that used to be taboo — "verification." It is not an offer. But '
          'it is a door.',
    ),
    source: const LText(
      'AI 2040 — Vorlauf des Verhandlungsfensters',
      'AI 2040 — lead-up to the negotiation window',
    ),
    minTurn: 3,
    maxTurn: 4,
    priority: 8,
    trigger: (s) =>
        s.metric(Metric.publicPressure) >= 30 || s.metric(Metric.trust) >= 25,
    choices: [
      EventChoice(
        label: const LText(
          'Geheime Sondierungsgespräche aufnehmen',
          'Open secret exploratory talks',
        ),
        description: const LText(
          'Kleine Delegationen, keine Presse. Ziel: ausloten, ob ein '
              'verifizierbares Abkommen überhaupt denkbar ist.',
          'Small delegations, no press. The goal: find out whether a '
              'verifiable treaty is even conceivable.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Drei Runden in Genf. Man misstraut einander gründlich — und '
                  'stellt fest, dass man dieselben Albträume hat. Ein '
                  'Verhandlungsmandat entsteht.',
              'Three rounds in Geneva. Both sides distrust each other '
                  'thoroughly — and discover they share the same nightmares. A '
                  'negotiating mandate is born.',
            ),
            effect: Effect(
              deltas: {Metric.trust: 12, Metric.politicalCapital: -4},
              newTreatyPhase: TreatyPhase.negotiation,
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Gespräche leaken. Falken beider Seiten sprechen von '
                  'Verrat, der Kanal friert vorerst ein — aber er existiert.',
              'The talks leak. Hawks on both sides cry betrayal, and the '
                  'channel freezes for now — but it exists.',
            ),
            effect: Effect(
              deltas: {
                Metric.trust: 4,
                Metric.politicalCapital: -10,
                Metric.publicPressure: 6,
              },
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Öffentlich Verhandlungen fordern',
          'Publicly call for negotiations',
        ),
        description: const LText(
          'Eine große Rede: Amerika sei bereit, über gemeinsame Grenzen für '
              'Superintelligenz zu verhandeln — verifizierbar und gegenseitig.',
          'A major speech: America is ready to negotiate shared limits on '
              'superintelligence — verifiable and mutual.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Die Rede setzt Peking unter Zugzwang. Nach Wochen des '
                  'Schweigens: Zustimmung zu „technischen Konsultationen". Der '
                  'Prozess ist öffentlich — und damit träger, aber legitimer.',
              'The speech puts Beijing on the spot. After weeks of '
                  'silence: agreement to "technical consultations." The '
                  'process is public — which makes it slower, but more '
                  'legitimate.',
            ),
            effect: Effect(
              deltas: {Metric.trust: 8, Metric.publicPressure: 8},
              newTreatyPhase: TreatyPhase.negotiation,
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Peking wertet den Vorstoß als Propaganda und verweist auf '
                  '„hegemoniale Exportkontrollen". Die Tür bleibt einen Spalt '
                  'offen, mehr nicht.',
              'Beijing dismisses the move as propaganda and points to '
                  '"hegemonic export controls." The door stays open a crack, '
                  'no more.',
            ),
            effect: Effect(
              deltas: {Metric.publicPressure: 6, Metric.trust: -3},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Abwinken — Vorsprung ausbauen',
          'Wave it off, extend the lead',
        ),
        description: const LText(
          'Verhandeln kann man später, aus einer Position der Stärke. '
              'Jetzt: Exportkontrollen verschärfen, Compute sichern.',
          'Negotiating can wait until it is done from a position of '
              'strength. For now: tighten export controls, lock down compute.',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Die Kontrollen beißen. Chinas Aufholjagd verlangsamt sich — '
                  'und verlagert sich in Programme, die kein Satellit sieht.',
              'The controls bite. China\'s catch-up effort slows down — '
                  'and shifts into programs no satellite will ever see.',
            ),
            effect: Effect(
              deltas: {
                Metric.cnCapability: -5,
                Metric.trust: -10,
                Metric.covertRisk: 10,
              },
            ),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Peking antwortet mit Rohstoff-Embargos und einem nationalen '
                  'Compute-Programm. Das Rennen wird härter, das Fenster für '
                  'Gespräche schließt sich fürs Erste.',
              'Beijing answers with raw-material embargoes and a national '
                  'compute program. The race gets harder, and the window for '
                  'talks closes for now.',
            ),
            effect: Effect(
              deltas: {
                Metric.cnCapability: 2,
                Metric.trust: -12,
                Metric.covertRisk: 8,
                Metric.politicalCapital: 4,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'election_2028',
    title: const LText('AI on the Ballot', 'AI on the Ballot'),
    description: const LText(
      'Wahljahr 2028. Die Rechenzentren im Bau kosten inzwischen das '
          'Doppelte des gesamten US-Militärbudgets, die Büroetagen erleben, was '
          'die Software-Branche 2026 erlebt hat — und zum ersten Mal ist KI DAS '
          'Wahlkampfthema. Beide Kandidaten verlangen von dir eine Linie: '
          'Worauf soll die nächste Regierung zusteuern?',
      'Election year 2028. The data centers under construction now cost '
          'twice the entire US military budget; white-collar offices are '
          'living through what the software industry lived through in 2026 — '
          'and for the first time, AI is THE campaign issue. Both candidates '
          'want a line from you: what should the next administration steer '
          'toward?',
    ),
    source: const LText(
      'AI 2040 — „2028: AI on the Ballot"',
      'AI 2040 — "2028: AI on the Ballot"',
    ),
    minTurn: 4,
    maxTurn: 4,
    priority: 9,
    choices: [
      EventChoice(
        label: const LText(
          'Mandat für einen Deal erkämpfen',
          'Fight for a mandate to make a deal',
        ),
        description: const LText(
          'Die Kampagne stellt das kommende KI-Abkommen ins Zentrum: Wer '
              'gewinnt, gewinnt mit dem Auftrag, mit Peking zu verhandeln.',
          'The campaign puts the coming AI treaty at its center: whoever '
              'wins, wins with a mandate to negotiate with Beijing.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Es funktioniert: Die Wahl wird zur Abstimmung über '
                  'Kontrolle statt Tempo. Die neue Regierung tritt mit einem '
                  'klaren Verhandlungsmandat an — Peking registriert es genau.',
              'It works: the election becomes a referendum on control '
                  'instead of speed. The new administration takes office with '
                  'a clear negotiating mandate — and Beijing takes careful '
                  'note.',
            ),
            effect: Effect(
              deltas: {
                Metric.publicPressure: 8,
                Metric.trust: 6,
                Metric.politicalCapital: 10,
              },
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Botschaft zerfasert im Kulturkampf. Das Mandat ist da, '
                  'aber dünn — jede Kongressabstimmung wird ein Kraftakt.',
              'The message frays in the culture war. The mandate exists, '
                  'but it is thin — every vote in Congress becomes a fight.',
            ),
            effect: Effect(
              deltas: {Metric.publicPressure: 5, Metric.politicalCapital: 2},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Auf Stärke setzen', 'Bet on strength'),
        description: const LText(
          '„America leads": Compute-Dominanz, Exportkontrollen, keine '
              'Zugeständnisse. Verhandelt wird höchstens aus der Pole-Position.',
          '"America leads": compute dominance, export controls, no '
              'concessions. If there is negotiating to be done, it happens '
              'from pole position, or not at all.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Die Härte-Rhetorik gewinnt Stimmen und kostet Kanäle: In '
                  'Peking gelten Gespräche jetzt als innenpolitisches Risiko.',
              'The tough talk wins votes and costs channels: in Beijing, '
                  'talks now count as a domestic political liability.',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: 8,
                Metric.trust: -8,
                Metric.usCapability: 2,
              },
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Der Überbietungswettbewerb der Kandidaten eskaliert bis zu '
                  '„KI-Manhattan-Projekt"-Versprechen. Das Rennen bekommt '
                  'Wahlkampf-Rückenwind.',
              'The candidates\' bidding war escalates all the way to '
                  'promises of an "AI Manhattan Project." The race gets a '
                  'campaign-trail tailwind.',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: 6,
                Metric.trust: -10,
                Metric.usCapability: 3,
                Metric.covertRisk: 5,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'choose_a_path',
    title: const LText('2029: Choose a Path', '2029: Choose a Path'),
    description: const LText(
      'Die Wahl ist entschieden, die Intelligenzexplosion absehbar — ohne '
          'Eingriff erreicht das Rennen um 2030 die volle Automatisierung der '
          'KI-Forschung und noch im selben Jahr die Superintelligenz. '
          'Präsident und designierter Nachfolger sitzen mit dir im Situation '
          'Room. Fünf Pläne liegen auf dem Tisch. Einer wird Amerikas Kurs.',
      'The election is settled, the intelligence explosion in sight. Left '
          'unchecked, the race reaches full automation of AI research by '
          '2030, and superintelligence in the same year. The President and '
          'the president-elect sit with you in the Situation Room. Five plans '
          'are on the table. One becomes America\'s course.',
    ),
    source: const LText(
      'AI 2040 — „2029: Choose a Path" (der zentrale Fork)',
      'AI 2040 — "2029: Choose a Path" (the central fork)',
    ),
    minTurn: 5,
    maxTurn: 6,
    priority: 20,
    choices: [
      EventChoice(
        label: const LText(
          'Plan A — The Deal (Verified Slowdown)',
          'Plan A — The Deal (Verified Slowdown)',
        ),
        description: const LText(
          'China und weiteren Staaten einen verifizierten Deal anbieten: '
              'volle Forschungstransparenz, Chip-Tracking, Inspektionen, '
              'Zerstörungsklausel. Gemeinsam langsam statt heimlich schnell.',
          'Offer China and other states a verified deal: full research '
              'transparency, chip tracking, inspections, a destruction '
              'clause. Slow together instead of fast in secret.',
        ),
        enabledIf: (s) =>
            s.treatyPhase == TreatyPhase.negotiation ||
            s.metric(Metric.trust) >= 30,
        lockedHint: const LText(
          'Ohne Verhandlungskanal nach Peking (Vertrauen mindestens 30 '
              'oder laufende Sondierungen) ist kein Deal zu machen.',
          'Without a channel to Beijing (trust of at least 30, or talks '
              'already underway), there is no deal to be had.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Januar 2029: Beide Seiten legen ihre Chip-Bestände offen — '
                  '224 Millionen H100-Äquivalente auf US-Seite, 26 Millionen '
                  'auf chinesischer. Inspektionsteams, Netzwerk-Taps, '
                  'Zerstörungsklausel: Der Vertrag steht, mit allen Zähnen.',
              'January 2029: both sides disclose their chip stockpiles — '
                  '224 million H100 equivalents on the US side, 26 million on '
                  'the Chinese. Inspection teams, network taps, a destruction '
                  'clause: the treaty stands, and it has teeth.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 25,
                Metric.trust: 10,
                Metric.politicalCapital: -8,
              },
              newTreatyPhase: TreatyPhase.signed,
              setFlags: {'plan_a', 'vertrag_voll'},
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Der Deal kommt zustande — abgeschwächt. Der Senat streicht '
                  'Teile der Inspektionsrechte, Peking spiegelt jede '
                  'Aufweichung. Was bleibt, ist ein Vertrag mit '
                  'Ermessensspielräumen. Beide Seiten wissen, was das heißt.',
              'The deal comes together, watered down. The Senate strikes '
                  'parts of the inspection rights, and Beijing mirrors every '
                  'concession. What remains is a treaty full of discretionary '
                  'loopholes. Both sides know exactly what that means.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 13,
                Metric.trust: 6,
                Metric.covertRisk: 8,
                Metric.politicalCapital: -10,
              },
              newTreatyPhase: TreatyPhase.signed,
              setFlags: {'plan_a', 'vertrag_light'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Plan S — Shut it all down',
          'Plan S — Shut it all down',
        ),
        description: const LText(
          'Das globale Moratorium: aller Frontier-Fortschritt stoppt, '
              'Chips werden getrackt, Algorithmenforschung verboten. '
              'Bestehende Modelle bleiben online — mehr kommt nicht dazu.',
          'The global moratorium: all frontier progress stops, chips get '
              'tracked, algorithm research is banned. Existing models stay '
              'online — nothing more gets added.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Peking stimmt zu — schneller als erwartet, aus Angst vor '
                  'dem US-Compute-Vorsprung. Bis Ende 2030 deckt das '
                  'Konsortium 99 Prozent des globalen KI-Computes ab. Die '
                  'Frontier friert ein; die Welt hält den Atem an.',
              'Beijing agrees — faster than expected, out of fear of the '
                  'US compute lead. By the end of 2030 the consortium covers '
                  '99 percent of global AI compute. The frontier freezes; the '
                  'world holds its breath.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 18,
                Metric.trust: 8,
                Metric.politicalCapital: -10,
              },
              newTreatyPhase: TreatyPhase.moratorium,
              setFlags: {'plan_s'},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Peking stimmt zu — und die eigene Industrie läuft Sturm. '
                  'Bewertungen stürzen, Klagen fliegen, zwei Gouverneure '
                  'verweigern die Umsetzung. Das Moratorium steht, aber es '
                  'steht auf einem Bein.',
              'Beijing agrees — and the domestic industry revolts. '
                  'Valuations crash, lawsuits fly, two governors refuse to '
                  'enforce it. The moratorium stands, but it stands on one '
                  'leg.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 12,
                Metric.trust: 6,
                Metric.politicalCapital: -18,
              },
              newTreatyPhase: TreatyPhase.moratorium,
              setFlags: {'plan_s'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Plan C — Burn the Lead', 'Plan C — Burn the Lead'),
        description: const LText(
          'Kein Staatsvertrag: Das führende US-Lab verbrennt freiwillig '
              'seinen Vorsprung für Sicherheitsforschung, andere ziehen '
              'vielleicht nach. Monate gewinnen, nicht Jahre.',
          'No state treaty: the leading US lab voluntarily burns its lead '
              'on safety research, and others might follow suit. You buy '
              'months, not years.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Der Präsident überzeugt das führende Lab zur Pause. Ein '
                  'paar Monate lang fließt der Vorsprung in Alignment-Arbeit — '
                  'während die Konkurrenz aufholt und die Investoren zählen.',
              'The President talks the leading lab into a pause. For a '
                  'few months the lead flows into alignment work — while the '
                  'competition catches up and the investors keep count.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 7,
                Metric.usCapability: -2,
                Metric.publicPressure: 4,
              },
              newTreatyPhase: TreatyPhase.none,
              setFlags: {'plan_c'},
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Die Labs bekämpfen jede Bremsung mit einer „AI Good"-'
                  'Kampagne. Die Pause kommt trotzdem — kleiner, später, '
                  'zäher.',
              'The labs fight every slowdown with an "AI Good" campaign. '
                  'The pause happens anyway — smaller, later, and harder-won.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 4,
                Metric.publicPressure: 6,
                Metric.politicalCapital: -6,
              },
              newTreatyPhase: TreatyPhase.none,
              setFlags: {'plan_c'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Plan B — Fight China', 'Plan B — Fight China'),
        description: const LText(
          'Zeit kaufen durch Sabotage: Cyberangriffe und Lieferketten-'
              'Operationen gegen Chinas KI-Programm, um den eigenen Vorsprung '
              'für Sicherheit zu nutzen. Monate Vorsprung — zum Preis der '
              'Eskalation.',
          'Buy time through sabotage: cyberattacks and supply-chain '
              'operations against China\'s AI program, spending the lead you '
              'buy on safety work. Months of lead time — at the price of '
              'escalation.',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Die Operationen greifen: Chinas Programm verliert Monate. '
                  'Peking weiß genau, woher der Schaden kommt — und beginnt, '
                  'in Kategorien zu planen, die kein Inspektionsregime je '
                  'sehen wird.',
              'The operations land: China\'s program loses months. '
                  'Beijing knows exactly where the damage came from — and '
                  'starts planning in categories no inspection regime will '
                  'ever see.',
            ),
            effect: Effect(
              deltas: {
                Metric.cnCapability: -8,
                Metric.trust: -15,
                Metric.covertRisk: 10,
              },
              newTreatyPhase: TreatyPhase.none,
              setFlags: {'plan_b'},
            ),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Eine Operation fliegt auf. Peking präsentiert Beweise vor '
                  'dem Sicherheitsrat, Verbündete gehen auf Distanz, und der '
                  'Cyberkrieg um die KI-Programme beginnt offiziell.',
              'One operation gets exposed. Beijing presents evidence to '
                  'the Security Council, allies keep their distance, and the '
                  'cyberwar over AI programs officially begins.',
            ),
            effect: Effect(
              deltas: {
                Metric.cnCapability: -4,
                Metric.trust: -20,
                Metric.covertRisk: 12,
                Metric.publicPressure: 6,
              },
              newTreatyPhase: TreatyPhase.none,
              setFlags: {'plan_b'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Plan D — Race to ASI', 'Plan D — Race to ASI'),
        description: const LText(
          '„Light-touch regulation": Wer zuerst die Superintelligenz hat, '
              'macht die Regeln. Volles Tempo durch die Intelligenzexplosion — '
              'Sicherheit bekommt, was übrig bleibt.',
          '"Light-touch regulation": whoever gets superintelligence first '
              'makes the rules. Full speed through the intelligence '
              'explosion — safety gets whatever is left over.',
        ),
        outcomes: [
          const Outcome(
            weight: 20,
            text: LText(
              'Im Juli 2029 verkündet der Präsident den Innovationskurs. '
                  'Die Labs koppeln ihre stärksten Systeme in die eigene '
                  'Forschung, die Kurven werden senkrecht. Es ist das Rennen, '
                  'vor dem alle Papiere gewarnt haben — und Amerika läuft es '
                  'freiwillig.',
              'In July 2029, the President announces the innovation '
                  'course. The labs feed their strongest systems back into '
                  'their own research, and the curves go vertical. It is the '
                  'race every paper warned about — and America runs it '
                  'willingly.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: 4,
                Metric.cnCapability: 2,
                Metric.alignment: -3,
                Metric.trust: -8,
                Metric.covertRisk: 6,
              },
              newTreatyPhase: TreatyPhase.none,
              setFlags: {'plan_d'},
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'throttle_begins',
    title: const LText('Die Drosselung beginnt', 'The Throttling Begins'),
    description: const LText(
      'Der Vertrag greift: Neue Frontier-Trainingsläufe oberhalb der '
          'vereinbarten Compute-Schwelle werden gestoppt, das Chip-Tracking '
          'läuft, die ersten Rechenzentren bekommen ihre Netzwerk-Taps. Die '
          'Neuproduktion sinkt um ein Fünftel gegenüber dem Rennpfad. Zum '
          'ersten Mal seit Jahren wächst die KI-Fähigkeit langsamer als die '
          'Alignment-Forschung.',
      'The treaty takes hold: new frontier training runs above the agreed '
          'compute threshold are stopped, chip tracking goes live, and the '
          'first data centers get their network taps. New production drops '
          'by a fifth compared to the race path. For the first time in years, '
          'AI capability grows slower than alignment research.',
    ),
    source: const LText(
      'AI 2040 — Verification Plan, Phase 2 (2029/2030)',
      'AI 2040 — Verification Plan, Phase 2 (2029/2030)',
    ),
    minTurn: 5,
    maxTurn: 12,
    priority: 9,
    trigger: (s) => s.treatyPhase == TreatyPhase.signed,
    effect: const Effect(
      deltas: {Metric.alignment: 4},
      newTreatyPhase: TreatyPhase.throttle,
    ),
  ),
];
