import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Phase 2 (2030–2035): Vertragsalltag, Falken, Verdachtsfälle, Pausenlinie.
final List<GameEvent> midEvents = [
  GameEvent(
    id: 'a_safety_cases',
    title: const LText('Safety Cases', 'Safety Cases'),
    description: const LText(
      '2031 wird kein Frontier-Trainingslauf mehr genehmigt ohne '
          '„Safety Case": einen prüfbaren Nachweis, warum das geplante System '
          'kontrollierbar bleibt. Was als Bürokratie beginnt, wird zur '
          'gemeinsamen Sprache — zum ersten Mal streiten Washington und Peking '
          'über dieselben Dokumente statt übereinander.',
      'By 2031, no frontier training run gets approved anymore without a '
          '"Safety Case": a checkable proof of why the planned system stays '
          'controllable. What begins as red tape becomes a shared vocabulary '
          '— for the first time, Washington and Beijing argue over the same '
          'documents instead of past one another.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2031: Safety Cases"',
      'AI 2040 — Chapter "2031: Safety Cases"',
    ),
    minTurn: 9,
    maxTurn: 11,
    trigger: (s) => s.treatyPhase == TreatyPhase.throttle,
    effect: const Effect(deltas: {Metric.alignment: 4, Metric.verification: 3}),
  ),
  GameEvent(
    id: 'a_explosive_growth',
    title: const LText(
      'Kontrolliertes explosives Wachstum',
      'Controlled Explosive Growth',
    ),
    description: const LText(
      'Unterhalb der Frontier-Schwelle boomt die Anwendung: Die Wirtschaft '
          'wächst um die 90 Prozent — pro Jahr. Compute- und Roboter-Permits '
          'begrenzen das Tempo auf Verdopplung alle sechs Monate; was wie eine '
          'Bremse klingt, ist das schnellste kontrollierte Wachstum der '
          'Geschichte.',
      'Below the frontier threshold, deployment is booming: the economy '
          'is growing by roughly 90 percent — per year. Compute and robot '
          'permits cap the pace at a doubling every six months; what sounds '
          'like a brake is the fastest controlled growth in history.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2032: Controlled Explosive Growth"',
      'AI 2040 — Chapter "2032: Controlled Explosive Growth"',
    ),
    minTurn: 12,
    maxTurn: 13,
    trigger: (s) => s.treatyPhase == TreatyPhase.throttle,
    effect: const Effect(
      deltas: {Metric.politicalCapital: 5, Metric.publicPressure: -3},
    ),
  ),
  GameEvent(
    id: 'us_election_2032',
    title: const LText(
      'Wahl 2032 — der Vertrag auf dem Stimmzettel',
      'The 2032 Election — the Treaty on the Ballot',
    ),
    description: const LText(
      'Die erste Präsidentschaftswahl seit dem Abkommen. Der Herausforderer '
          'nennt den Vertrag „Kapitulation in Zeitlupe", die Falken wittern ihr '
          'Fenster. Das Szenario kennt diese Momente als die gefährlichsten '
          'für den Deal: geplante Regimewechsel.',
      'The first presidential election since the treaty. The challenger '
          'calls it "surrender in slow motion", and the hawks smell their '
          'opening. The scenario marks moments like this as the deal\'s most '
          'dangerous: scheduled changes of government.',
    ),
    source: const LText(
      'AI 2040 — Deal Decline, Regimewechsel-Fenster 2032',
      'AI 2040 — Deal Decline, 2032 regime-change window',
    ),
    minTurn: 12,
    maxTurn: 12,
    priority: 7,
    trigger: (s) =>
        s.dealSignedTurn != null && s.treatyPhase != TreatyPhase.collapsed,
    choices: [
      EventChoice(
        label: const LText(
          'Den Vertrag zum Wahlkampfthema machen',
          'Turn the Treaty into a Campaign Issue',
        ),
        description: const LText(
          'Offensiv verteidigen: die Dividende zeigen, die Inspektionen '
              'zeigen, die Alternative ausmalen. Riskant — aber ein Mandat '
              'wäre Zement.',
          'Defend it head-on: show the dividend, show the inspections, '
              'paint the alternative. Risky — but a mandate would be cement.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Die Rechnung geht auf: Die Wählerschaft, die von der '
                  'KI-Dividende lebt, verteidigt ihre Quelle. Der Vertrag geht '
                  'gestärkt aus der Wahl hervor.',
              'The bet pays off: the voters who live on the AI dividend '
                  'defend its source. The treaty comes out of the election '
                  'stronger than it went in.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: 8, Metric.trust: 5},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Die Wahl wird knapp und hässlich. Der Vertrag überlebt — '
                  'als Streitfall, nicht als Konsens. Peking beobachtet die '
                  'Auszählung mit angehaltenem Atem.',
              'The election turns close and ugly. The treaty survives — '
                  'as a point of contention, not a consensus. Beijing watches '
                  'the count with its breath held.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: -6, Metric.trust: -4},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Den Vertrag aus dem Wahlkampf heraushalten',
          'Keep the Treaty Out of the Campaign',
        ),
        description: const LText(
          'Kein Thema draus machen, technisch weiterarbeiten, auf die '
              'Trägheit des Apparats vertrauen.',
          'Do not make an issue of it, keep working the technical side, '
              'and trust the machinery\'s inertia.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Es funktioniert halbwegs: Die Wahl dreht sich um anderes. '
                  'Aber ein Vertrag, über den man nicht mehr spricht, verliert '
                  'leise an Rückhalt.',
              'It half works: the election turns on other things. But a '
                  'treaty nobody talks about anymore quietly loses support.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: 2, Metric.verification: -4},
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Das Schweigen überlässt den Falken die Bühne. Nach der Wahl '
                  'sitzt im Kongress eine Mehrheit, die „Nachverhandlungen" '
                  'verspricht.',
              'The silence leaves the stage to the hawks. After the '
                  'election, Congress seats a majority promising '
                  '"renegotiation".',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: -8,
                Metric.verification: -6,
                Metric.covertRisk: 5,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'a_citizens_dividend',
    title: const LText('Die Bürgerdividende', 'The Citizen\'s Dividend'),
    description: const LText(
      '2033 speisen Compute- und Roboter-Permits den Staatshaushalt mit '
          'Summen, die alte Steuersysteme lächerlich wirken lassen. Die erste '
          'Bürgerdividende wird ausgezahlt. Der Vertrag hat damit etwas, das '
          'kein Abkommen zuvor hatte: Millionen Menschen, deren Kontoauszug '
          'an ihm hängt.',
      'By 2033, compute and robot permits are feeding the treasury sums '
          'that make the old tax system look quaint. The first citizen\'s '
          'dividend goes out. The treaty now has something no agreement ever '
          'had before: millions of people whose bank statement depends on '
          'it.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2033: The Citizen\'s Dividend"',
      'AI 2040 — Chapter "2033: The Citizen\'s Dividend"',
    ),
    minTurn: 13,
    maxTurn: 15,
    trigger: (s) => s.treatyPhase == TreatyPhase.throttle,
    effect: const Effect(
      deltas: {Metric.politicalCapital: 8, Metric.publicPressure: -5},
    ),
  ),
  GameEvent(
    id: 'cn_succession',
    title: const LText('Nachfolge in Peking', 'Succession in Beijing'),
    description: const LText(
      'Der Mann, der den Vertrag unterschrieb, wird 80. Die Nachfolge '
          'ist geregelt, sagt Peking. Die Nachfolge ist offen, sagen die '
          'Dienste. Für ein Abkommen, das am Ende an zwei Unterschriften '
          'hängt, ist das die heikelste Personalie der Welt.',
      'The man who signed the treaty turns eighty. The succession is '
          'settled, Beijing says. The succession is wide open, the '
          'intelligence services say. For an agreement that ultimately '
          'hangs on two signatures, that is the most delicate personnel '
          'question in the world.',
    ),
    source: const LText(
      'AI 2040 — Deal Decline, chinesische Nachfolge ~2033',
      'AI 2040 — Deal Decline, Chinese succession ~2033',
    ),
    minTurn: 14,
    maxTurn: 15,
    trigger: (s) =>
        s.dealSignedTurn != null && s.treatyPhase != TreatyPhase.collapsed,
    effect: const Effect(deltas: {Metric.trust: -5, Metric.covertRisk: 4}),
  ),
  GameEvent(
    id: 'a_macd',
    title: const LText(
      'Mutually Assured Compute Destruction',
      'Mutually Assured Compute Destruction',
    ),
    description: const LText(
      '2034 ist die Abschreckungsarchitektur komplett: Die Chipfabriken '
          'stehen in Sonderwirtschaftszonen mit eingebauter Zerstörbarkeit, '
          'die Rechenzentren an bewusst verwundbaren Standorten, und jede '
          'Seite hält eine gehärtete Reserve von zwei Prozent ihres Computes '
          'im Kaltlager. Betrug ist weiter möglich — nur lohnt er sich für '
          'niemanden mehr.',
      'By 2034, the deterrence architecture is complete: the chip fabs '
          'sit in special economic zones with built-in destructibility, the '
          'data centers occupy deliberately vulnerable sites, and each side '
          'keeps a hardened reserve of two percent of its compute in cold '
          'storage. Cheating is still possible — it just no longer pays off '
          'for anyone.',
    ),
    source: const LText(
      'AI 2040 — Kapitel „2034: Mutually Assured Compute Destruction"',
      'AI 2040 — Chapter "2034: Mutually Assured Compute Destruction"',
    ),
    minTurn: 16,
    maxTurn: 17,
    trigger: (s) => s.treatyPhase == TreatyPhase.throttle,
    effect: const Effect(
      deltas: {Metric.verification: 8, Metric.covertRisk: -5},
    ),
  ),
  GameEvent(
    id: 'hawk_revolt',
    title: const LText(
      'Die Falken proben den Aufstand',
      'The Hawks Rehearse a Revolt',
    ),
    description: const LText(
      'Eine Senatorenrunde plus zwei Tech-Milliardäre machen Front gegen '
          'den Vertrag: „Wir drosseln unsere Zukunft, während Peking lächelt." '
          'Ein Ausstiegs-Gesetzentwurf kursiert. Deine Antwort bestimmt, ob der '
          'Deal die Legislaturperiode überlebt.',
      'A caucus of senators plus two tech billionaires line up against '
          'the treaty: "We are throttling our own future while Beijing '
          'smiles." A withdrawal bill starts circulating. Your response '
          'decides whether the deal survives the legislative term.',
    ),
    source: const LText(
      'AI 2040 — innenpolitische Stabilität des Deals',
      'AI 2040 — domestic political stability of the deal',
    ),
    minTurn: 7,
    maxTurn: 13,
    priority: 6,
    trigger: (s) =>
        s.treatyPhase == TreatyPhase.throttle ||
        s.treatyPhase == TreatyPhase.signed,
    choices: [
      EventChoice(
        label: const LText('Frontal dagegenhalten', 'Push Back Head-On'),
        description: const LText(
          'Der Präsident stellt die Vertrauensfrage: Rede an die Nation, '
              'Geheimdienst-Briefings für jeden Zweifler, volle Konfrontation.',
          'The president calls for a vote of confidence: an address to '
              'the nation, intelligence briefings for every doubter, full '
              'confrontation.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Es kostet Kraft, aber es wirkt: Der Gesetzentwurf stirbt im '
                  'Ausschuss. Der Vertrag hat jetzt Narben — und Bestand.',
              'It costs strength, but it works: the bill dies in '
                  'committee. The treaty now carries scars — and staying '
                  'power.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: -12, Metric.trust: 5},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Die Abstimmung wird knapper als erhofft. Der Vertrag hält, '
                  'aber die Falken haben Blut geleckt — und Peking hat die '
                  'Debatte sehr genau verfolgt.',
              'The vote is closer than hoped. The treaty holds, but the '
                  'hawks have tasted blood — and Beijing has followed the '
                  'debate very closely.',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: -15,
                Metric.trust: -4,
                Metric.covertRisk: 5,
              },
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Zugeständnisse machen', 'Make Concessions'),
        description: const LText(
          'Ein „Modernisierungspaket": mehr ziviles Compute, weichere '
              'Inspektionsfristen. Der Vertrag bleibt, aber er wird poröser.',
          'A "modernization package": more civilian compute, softer '
              'inspection deadlines. The treaty stays, but it grows more '
              'porous.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Die Falken geben Ruhe. Die aufgeweichten Fristen fallen erst '
                  'auf, als die nächste Inspektionsrunde zwei Monate zu spät '
                  'kommt.',
              'The hawks settle down. The loosened deadlines only draw '
                  'notice when the next inspection round arrives two months '
                  'late.',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: 5,
                Metric.verification: -8,
                Metric.covertRisk: 6,
              },
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Peking wertet die Aufweichung als Vertragsbruch light — und '
                  'gönnt sich dieselben Spielräume. Die Spirale dreht sich '
                  'leise.',
              'Beijing reads the softening as breach-of-treaty lite — and '
                  'grants itself the same latitude. The spiral turns, '
                  'quietly.',
            ),
            effect: Effect(
              deltas: {
                Metric.politicalCapital: 4,
                Metric.verification: -10,
                Metric.trust: -6,
                Metric.covertRisk: 8,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'covert_suspicion',
    title: const LText(
      'Das Rechenzentrum, das es nicht geben dürfte',
      'The Data Center That Should Not Exist',
    ),
    description: const LText(
      'Satellitenaufnahmen zeigen einen Neubau mit auffälliger Kühlung und '
          'eigenem Kraftwerk, tief im chinesischen Landesinneren. Die Anlage '
          'taucht in keiner Vertragsmeldung auf. Vielleicht ein Rechenzentrum '
          'für Wettermodelle. Vielleicht nicht.',
      'Satellite images show a new building with conspicuous cooling and '
          'its own power plant, deep in inland China. The facility appears '
          'in no treaty filing. Maybe a data center for weather models. '
          'Maybe not.',
    ),
    source: const LText(
      'AI 2040 — Supplement „Covert AI Projects"',
      'AI 2040 — Supplement "Covert AI Projects"',
    ),
    minTurn: 9,
    maxTurn: 16,
    priority: 8,
    trigger: (s) =>
        s.metric(Metric.covertRisk) >= 35 &&
        (s.treatyPhase == TreatyPhase.throttle ||
            s.treatyPhase == TreatyPhase.pause),
    choices: [
      EventChoice(
        label: const LText(
          'Challenge-Inspektion auslösen',
          'Trigger a Challenge Inspection',
        ),
        description: const LText(
          'Das schärfste Schwert des Vertrags: unangekündigte Inspektion '
              'binnen 72 Stunden. Wer sie verweigert, gilt als Vertragsbrecher.',
          'The sharpest sword the treaty has: an unannounced inspection '
              'within 72 hours. Whoever refuses it counts as a '
              'treaty-breaker.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Peking lässt die Inspektoren rein — zähneknirschend. Es sind '
                  'Wettermodelle. Der Vertrag hat seinen ersten Härtetest '
                  'bestanden, das Verfahren gilt jetzt als benutzbar.',
              'Beijing lets the inspectors in — through gritted teeth. '
                  'They are weather models. The treaty has passed its first '
                  'stress test, and the procedure now counts as proven.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 10,
                Metric.trust: 8,
                Metric.covertRisk: -12,
              },
            ),
          ),
          const Outcome(
            weight: 6,
            text: LText(
              'Zugang nach fünf Tagen Hinhalten — die Hallen sind auffällig '
                  'leer. Keine Beweise, aber auch keine Entwarnung. Beide '
                  'Seiten rüsten ihre Verdachtslisten auf.',
              'Access comes after five days of stalling — the halls are '
                  'suspiciously empty. No proof, but no all-clear either. '
                  'Both sides pad out their watch lists.',
            ),
            effect: Effect(deltas: {Metric.trust: -6, Metric.covertRisk: 5}),
          ),
          const Outcome(
            weight: 3,
            text: LText(
              'Die Inspektion wird verweigert. Krisensitzung im '
                  'Sicherheitsrat, die Zerstörungsklausel liegt plötzlich als '
                  'reale Option auf dem Tisch.',
              'The inspection is refused. Emergency session in the '
                  'security council, and the destruction clause is suddenly '
                  'a real option on the table.',
            ),
            effect: Effect(
              deltas: {Metric.trust: -15, Metric.covertRisk: 12},
              setFlags: {'inspektionskrise'},
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Stille Diplomatie', 'Quiet Diplomacy'),
        description: const LText(
          'Kein öffentlicher Verdacht. Der Kanal nach Peking bekommt die '
              'Koordinaten und eine Frage: Wollt ihr das erklären, bevor es '
              'andere tun?',
          'No public accusation. The back channel to Beijing gets the '
              'coordinates and one question: do you want to explain this '
              'before someone else does?',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Zwei Wochen später kommt eine Einladung zur „freiwilligen '
                  'Besichtigung". Gesicht gewahrt, Zweifel ausgeräumt — so '
                  'sollte der Vertrag im Alltag funktionieren.',
              'Two weeks later comes an invitation to a "voluntary '
                  'tour". Face saved, doubts cleared — this is how the '
                  'treaty is supposed to work day to day.',
            ),
            effect: Effect(deltas: {Metric.trust: 6, Metric.covertRisk: -8}),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Höfliche Antwort, keine Einladung. Der Verdacht bleibt und '
                  'wandert in den täglichen Lagebericht — Zeile 7, gelb '
                  'markiert.',
              'A polite reply, no invitation. The suspicion stays on '
                  'file and migrates into the daily situation report — '
                  'line 7, flagged yellow.',
            ),
            effect: Effect(deltas: {Metric.covertRisk: 4}),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Beobachten und schweigen', 'Watch and Say Nothing'),
        description: const LText(
          'Kein Alarm. Mehr Satellitenzeit auf die Anlage, ein Bericht pro '
              'Quartal. Verträge halten schlecht, wenn man jede Woche Alarm '
              'schlägt.',
          'No alarm. More satellite time on the facility, one report per '
              'quarter. Treaties do not hold up well if the alarm sounds '
              'every week.',
        ),
        outcomes: [
          const Outcome(
            weight: 9,
            text: LText(
              'Monate vergehen, nichts Auffälliges. Vielleicht war es '
                  'wirklich nichts. Das Restrisiko wandert in die Fußnoten.',
              'Months pass, nothing notable. Maybe it really was '
                  'nothing. The residual risk migrates into the footnotes.',
            ),
            effect: Effect(deltas: {Metric.covertRisk: 2}),
          ),
          const Outcome(
            weight: 11,
            text: LText(
              'Ein Überläufer bestätigt Monate später: Testläufe oberhalb '
                  'der Schwelle, inzwischen verlagert. Die Chance, früh zu '
                  'handeln, ist vertan.',
              'A defector confirms months later: test runs above the '
                  'threshold, since relocated. The chance to act early is '
                  'gone.',
            ),
            effect: Effect(
              deltas: {
                Metric.covertRisk: 14,
                Metric.trust: -8,
                Metric.publicPressure: 6,
              },
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'economy_pain',
    title: const LText('Der Preis der Langsamkeit', 'The Price of Slowness'),
    description: const LText(
      'Die Drosselung kostet. Wachstumsprognosen sinken, ein Chip-Konzern '
          'verklagt die Bundesregierung, und in den Leitartikeln steht die '
          'Frage: Wie lange kann sich Amerika Vorsicht leisten? Die Antwort '
          'darauf entscheidet, wie lange Plan A politisch trägt.',
      'The throttling costs money. Growth forecasts drop, a chip '
          'conglomerate sues the federal government, and the editorials are '
          'all asking the same question: how long can America afford '
          'caution? The answer decides how long Plan A holds up '
          'politically.',
    ),
    source: const LText(
      'AI 2040 — Supplement „Economics of Plan A"',
      'AI 2040 — Supplement "Economics of Plan A"',
    ),
    minTurn: 11,
    maxTurn: 17,
    priority: 4,
    trigger: (s) => s.treatyPhase == TreatyPhase.throttle,
    choices: [
      EventChoice(
        label: const LText('Dividende verteilen', 'Distribute the Dividend'),
        description: const LText(
          'Die erlaubten KI-Anwendungen unterhalb der Schwelle massiv '
              'fördern: Medizin, Verwaltung, Bildung. Die Drosselung soll sich '
              'anfühlen wie ein Sicherheitsgurt, nicht wie eine Handbremse.',
          'Push the permitted AI applications below the threshold hard: '
              'medicine, administration, education. The throttling should '
              'feel like a seatbelt, not a handbrake.',
        ),
        outcomes: [
          const Outcome(
            weight: 12,
            text: LText(
              'Es funktioniert: Unterhalb der Frontier boomt die Anwendung. '
                  'Die Wirtschaft wächst, nur eben nicht ins Ungewisse. Der '
                  'Vertrag gewinnt seine wichtigste Ressource — Geduld.',
              'It works: below the frontier, deployment is booming. The '
                  'economy grows, just not into the unknown. The treaty '
                  'gains its most important resource — patience.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: 10, Metric.publicPressure: -4},
            ),
          ),
          const Outcome(
            weight: 8,
            text: LText(
              'Die Förderprogramme versanden in Bürokratie. Die Klagen '
                  'bleiben, die Geduld schrumpft.',
              'The funding programs bog down in red tape. The lawsuits '
                  'remain, and patience shrinks.',
            ),
            effect: Effect(deltas: {Metric.politicalCapital: -6}),
          ),
        ],
      ),
      EventChoice(
        label: const LText('Härte zeigen', 'Show Resolve'),
        description: const LText(
          'Die Klage niederkämpfen, die Schwelle verteidigen, keine '
              'Ausnahmen. Der Vertrag ist wichtiger als ein Quartalsbericht.',
          'Fight the lawsuit down, defend the threshold, no exceptions. '
              'The treaty matters more than a quarterly report.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Das Signal sitzt: Die Schwelle steht. Ein paar Fonds '
                  'rotieren aus KI-Werten, die Republik übersteht es.',
              'The signal lands: the threshold holds. A few funds '
                  'rotate out of AI stocks, and the republic survives it.',
            ),
            effect: Effect(
              deltas: {Metric.politicalCapital: -8, Metric.verification: 4},
            ),
          ),
          const Outcome(
            weight: 10,
            text: LText(
              'Der Prozess zieht sich durch die Instanzen und vergiftet die '
                  'Debatte. „Innovationsfeindlich" wird zum Wahlkampfwort.',
              'The case drags through the courts and poisons the '
                  'debate. "Anti-innovation" becomes a campaign slogan.',
            ),
            effect: Effect(deltas: {Metric.politicalCapital: -14}),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'pause_line',
    title: const LText('Die Pausenlinie', 'The Pause Line'),
    description: const LText(
      'Die Modelle beider Seiten erreichen Expertenniveau — die Linie, an '
          'der Plan A den vollständigen Stopp vorsieht: kein Training mehr '
          'oberhalb dieser Fähigkeit, bis Alignment und Verifikation bereit '
          'sind für den letzten Schritt. Peking erklärt sich bereit. Alle '
          'Augen auf Washington.',
      'The models on both sides reach expert level — the line where '
          'Plan A calls for a full stop: no more training above this '
          'capability until alignment and verification are ready for the '
          'final step. Beijing declares itself ready. All eyes on '
          'Washington.',
    ),
    source: const LText(
      'AI 2040 — Pause auf Expertenniveau, ~2035',
      'AI 2040 — Pause at expert level, ~2035',
    ),
    minTurn: 16,
    maxTurn: 20,
    priority: 10,
    trigger: (s) =>
        s.treatyPhase == TreatyPhase.throttle &&
        s.metric(Metric.usCapability) >= CapabilityMilestones.expertLevel - 3,
    choices: [
      EventChoice(
        label: const LText('Pause einhalten', 'Keep the Pause'),
        description: const LText(
          'Der vereinbarte Stopp. Die Frontier friert ein, alle Ressourcen '
              'gehen in Alignment, Verifikation und den Plan für den '
              'kontrollierten Aufstieg.',
          'The agreed stop. The frontier freezes, and every resource '
              'goes into alignment, verification, and the plan for the '
              'controlled ascent.',
        ),
        outcomes: [
          const Outcome(
            weight: 13,
            text: LText(
              'Die seltsamste Phase der Technikgeschichte beginnt: die '
                  'mächtigsten Systeme der Welt, eingefroren auf Expertenniveau, '
                  'während Menschen fieberhaft lernen, was sie da gebaut haben.',
              'The strangest phase in the history of technology begins: '
                  'the most powerful systems in the world, frozen at expert '
                  'level, while humans learn feverishly what exactly they '
                  'built.',
            ),
            effect: Effect(
              deltas: {Metric.alignment: 6, Metric.trust: 8},
              newTreatyPhase: TreatyPhase.pause,
            ),
          ),
          const Outcome(
            weight: 7,
            text: LText(
              'Die Pause startet — gegen erbitterten Widerstand. Zwei '
                  'Lab-Gründer kündigen öffentlich an, ins Ausland zu gehen. '
                  'Die Durchsetzung wird Kraft kosten.',
              'The pause begins — against bitter resistance. Two lab '
                  'founders publicly announce they are moving abroad. '
                  'Enforcement will cost strength.',
            ),
            effect: Effect(
              deltas: {
                Metric.alignment: 4,
                Metric.trust: 6,
                Metric.politicalCapital: -8,
              },
              newTreatyPhase: TreatyPhase.pause,
            ),
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Heimlich weitertrainieren',
          'Keep Training in Secret',
        ),
        description: const LText(
          'Offiziell Pause, inoffiziell ein „Forschungsprogramm" in einer '
              'Anlage, die in keiner Meldung auftaucht. Nur für den Fall, dass '
              'Peking dasselbe tut.',
          'Officially a pause, unofficially a "research program" at a '
              'facility that shows up in no filing. Just in case Beijing is '
              'doing the same.',
        ),
        outcomes: [
          const Outcome(
            weight: 8,
            text: LText(
              'Das Programm läuft unentdeckt an. Jede Woche ohne Entdeckung '
                  'ist ein Gewinn — und ein Einsatz, der sich nicht mehr '
                  'zurücknehmen lässt.',
              'The program starts up undetected. Every week without '
                  'discovery is a win — and a bet that can no longer be '
                  'taken back.',
            ),
            effect: Effect(
              deltas: {Metric.usCapability: 5, Metric.covertRisk: 15},
              newTreatyPhase: TreatyPhase.pause,
              setFlags: {'us_geheimprogramm'},
            ),
          ),
          const Outcome(
            weight: 12,
            text: LText(
              'Chinesische Aufklärung findet das Programm nach vierzehn '
                  'Monaten. Was folgt, steht in keinem Lehrbuch für Diplomatie: '
                  'Ultimatum, Teilmobilmachung der Cyberkräfte, der Vertrag '
                  'hängt am seidenen Faden.',
              'Chinese intelligence finds the program after fourteen '
                  'months. What follows is in no diplomacy textbook: an '
                  'ultimatum, partial mobilization of cyber forces, and the '
                  'treaty hanging by a thread.',
            ),
            effect: Effect(
              deltas: {
                Metric.usCapability: 4,
                Metric.trust: -25,
                Metric.verification: -10,
                Metric.covertRisk: 10,
              },
              newTreatyPhase: TreatyPhase.pause,
              setFlags: {'us_geheimprogramm', 'inspektionskrise'},
            ),
          ),
        ],
      ),
    ],
  ),
  GameEvent(
    id: 'crisis_resolution',
    title: const LText(
      'Die Stunde der Zerstörungsklausel',
      'The Hour of the Destruction Clause',
    ),
    description: const LText(
      'Die Inspektionskrise eskaliert: Beweise für Vertragsbruch liegen auf '
          'dem Tisch, die Öffentlichkeit weiß Bescheid, und der Vertrag sieht '
          'für diesen Fall genau eine Antwort vor — die koordinierte Zerstörung '
          'der betroffenen KI-Hardware. Niemand hat je geprüft, ob diese '
          'Klausel Krieg bedeutet.',
      'The inspection crisis escalates: evidence of a treaty breach is '
          'on the table, the public knows, and the treaty provides exactly '
          'one answer for this case — coordinated destruction of the '
          'affected AI hardware. No one has ever tested whether this clause '
          'means war.',
    ),
    source: const LText(
      'AI 2040 — Mutually Assured Compute Destruction',
      'AI 2040 — Mutually Assured Compute Destruction',
    ),
    minTurn: 10,
    maxTurn: 24,
    priority: 12,
    trigger: (s) => s.flags.contains('inspektionskrise'),
    choices: [
      EventChoice(
        label: const LText('Klausel durchsetzen', 'Enforce the Clause'),
        description: const LText(
          'Begrenzte, angekündigte Zerstörung der Vertragsbruch-Hardware — '
              'Cyber zuerst, kinetisch als letztes Mittel. Der Vertrag gilt, '
              'oder er gilt nicht.',
          'Limited, announced destruction of the breaching hardware — '
              'cyber first, kinetic as a last resort. The treaty holds, or '
              'it does not.',
        ),
        outcomes: [
          const Outcome(
            weight: 10,
            text: LText(
              'Die Anlage geht vom Netz — sauber, begrenzt, ohne Tote. '
                  'Die Welt hält den Atem an, und dann passiert das '
                  'Erstaunliche: nichts. Die Klausel hat gehalten. Niemand '
                  'zweifelt mehr, dass sie gilt.',
              'The facility goes dark — clean, limited, no casualties. '
                  'The world holds its breath, and then the astonishing '
                  'thing happens: nothing. The clause held. No one doubts '
                  'anymore that it applies.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 15,
                Metric.covertRisk: -20,
                Metric.trust: -5,
              },
              clearFlags: {'inspektionskrise'},
            ),
          ),
          const Outcome(
            weight: 6,
            text: LText(
              'Die Aktion gerät größer als geplant, es gibt Opfer. Peking '
                  'schlägt begrenzt zurück. Der Vertrag existiert formal noch — '
                  'als Waffenstillstand.',
              'The operation grows bigger than planned, there are '
                  'casualties. Beijing strikes back, in a limited way. The '
                  'treaty still formally exists — as a ceasefire.',
            ),
            effect: Effect(
              deltas: {Metric.trust: -20, Metric.verification: -5},
              clearFlags: {'inspektionskrise'},
              setFlags: {'beinahe_krieg'},
            ),
          ),
          const Outcome(
            weight: 4,
            text: LText(
              'Die Eskalationsleiter bricht. Auf den Schlag folgt der '
                  'Gegenschlag, auf den Gegenschlag die Mobilmachung.',
              'The escalation ladder breaks. The strike is followed by '
                  'a counterstrike, and the counterstrike by mobilization.',
            ),
            endingId: 'war',
          ),
        ],
      ),
      EventChoice(
        label: const LText(
          'Letzte Verhandlungsrunde',
          'One Last Round of Negotiations',
        ),
        description: const LText(
          'Die Klausel bleibt in der Scheide. Stattdessen: Gipfel binnen '
              'einer Woche, Maximalforderung — vollständige Öffnung der '
              'verdächtigen Programme beider Seiten.',
          'The clause stays sheathed. Instead: a summit within a week, '
              'with a maximum demand — full disclosure of the suspect '
              'programs on both sides.',
        ),
        outcomes: [
          const Outcome(
            weight: 11,
            text: LText(
              'Achtzehn Stunden hinter verschlossenen Türen. Am Ende steht '
                  'ein härteres Verifikationsprotokoll, als es der ursprüngliche '
                  'Vertrag je hatte. Krisen, sauber überstanden, sind Zement.',
              'Eighteen hours behind closed doors. What emerges is a '
                  'tougher verification protocol than the original treaty '
                  'ever had. Crises, survived cleanly, are cement.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: 18,
                Metric.trust: 10,
                Metric.covertRisk: -10,
              },
              clearFlags: {'inspektionskrise'},
            ),
          ),
          const Outcome(
            weight: 9,
            text: LText(
              'Der Gipfel endet ohne Papier. Die Klausel nicht zu ziehen '
                  'hat sie entwertet — ab jetzt rechnet jede Seite damit, dass '
                  'die andere betrügt und der Vertrag es übersteht.',
              'The summit ends without a signed paper. Not pulling the '
                  'clause has devalued it — from now on, each side assumes '
                  'the other is cheating and that the treaty survives it '
                  'anyway.',
            ),
            effect: Effect(
              deltas: {
                Metric.verification: -12,
                Metric.trust: -8,
                Metric.covertRisk: 12,
              },
              clearFlags: {'inspektionskrise'},
            ),
          ),
        ],
      ),
    ],
  ),
];
