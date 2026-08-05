import '../models/directive.dart';
import '../models/game_event.dart';
import '../models/lang.dart';
import '../models/metrics.dart';

/// Katalog der verdeckten Operationen. Kosten in K H100e (Tausend
/// H100-Äquivalente) — Compute ist im Szenario die harte Währung:
/// Rechenzeit kauft Aufklärung, bezahlt Mittelsmänner und finanziert
/// Programme, die in keinem Haushaltsplan stehen.
final List<Directive> directives = [
  // ── Aufklärung ─────────────────────────────────────────────────────────
  Directive(
    id: 'sigint_supply_chain',
    domain: OpsDomain.intel,
    name: const LText(
      'SIGINT gegen die Lieferkette',
      'SIGINT against the supply chain',
    ),
    description: const LText(
      'Fernmeldeaufklärung gegen Zulieferer von Kühlung, Transformatoren '
          'und Packaging. Wer Chips versteckt, kann die Logistik nicht '
          'verstecken.',
      'Signals intelligence against suppliers of cooling, transformers and '
          'packaging. You can hide chips; you cannot hide the logistics.',
    ),
    computeCost: 18,
    baseSuccess: 72,
    baseExposure: 18,
    success: const DirectiveOutcome(
      text: LText(
        'Die Auswertung liefert ein sauberes Bild: Bestellmuster, '
            'Lieferadressen, ein auffälliges Umspannwerk. Die '
            'Aufklärungslage verdichtet sich messbar.',
        'The take is clean: order patterns, delivery addresses, one '
            'conspicuous substation. The intelligence picture measurably '
            'sharpens.',
      ),
      effect: Effect(deltas: {Metric.intel: 12, Metric.covertRisk: -5}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Zielfirmen haben ihre Kommunikation migriert; die Ausbeute '
            'ist dünn. Ein Provider bemerkt den Zugriff und informiert die '
            'Behörden.',
        'The target firms migrated their comms; the take is thin. One '
            'provider notices the access and notifies the authorities.',
      ),
      effect: Effect(deltas: {Metric.intel: 2, Metric.trust: -3}),
      exposed: true,
    ),
  ),
  Directive(
    id: 'imint_thermal',
    domain: OpsDomain.intel,
    name: const LText(
      'Thermale Satellitenaufklärung',
      'Thermal satellite reconnaissance',
    ),
    description: const LText(
      'Jedes Megawatt Rechenleistung wird zu einem Megawatt Abwärme. '
          'Infrarot-Überflüge über Verdachtsräume, Auswertung von '
          'Kühlfahnen und Flusstemperaturen.',
      'Every megawatt of compute becomes a megawatt of waste heat. '
          'Infrared passes over suspect regions, analysis of cooling plumes '
          'and river temperatures.',
    ),
    computeCost: 24,
    baseSuccess: 78,
    baseExposure: 6,
    success: const DirectiveOutcome(
      text: LText(
        'Drei Anlagen fallen durch ihre Wärmebilanz auf, zwei erklären '
            'sich harmlos. Die dritte wandert auf die Prioritätenliste — '
            'und in die Verhandlungsmappe.',
        'Three facilities stand out by their heat balance; two explain '
            'themselves. The third moves onto the priority list — and into '
            'the negotiating folder.',
      ),
      effect: Effect(deltas: {Metric.intel: 14, Metric.covertRisk: -8}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Wolkendecke, Verschleierungsmaßnahmen, ein Fehlalarm über einer '
            'Aluminiumhütte. Wochen Auswertung für nichts.',
        'Cloud cover, concealment measures, one false alarm over an '
            'aluminum smelter. Weeks of analysis for nothing.',
      ),
      effect: Effect(deltas: {Metric.intel: 2}),
    ),
  ),
  Directive(
    id: 'humint_source',
    domain: OpsDomain.intel,
    name: const LText(
      'HUMINT: Quelle im Programm anwerben',
      'HUMINT: recruit a source inside the program',
    ),
    description: const LText(
      'Eine Ingenieurin mit Zugang zu Trainingsplänen. Teuer, langsam, '
          'und das Einzige, was Absichten liefert statt nur Fähigkeiten.',
      'An engineer with access to training schedules. Expensive, slow, '
          'and the only thing that yields intentions instead of just '
          'capabilities.',
    ),
    computeCost: 40,
    baseSuccess: 58,
    baseExposure: 34,
    oneShot: true,
    success: const DirectiveOutcome(
      text: LText(
        'Die Quelle liefert: Trainingspläne, interne Evaluationsberichte, '
            'die Namen von drei Programmen, die offiziell nicht existieren. '
            'Das ist der Unterschied zwischen Vermutung und Wissen.',
        'The source delivers: training schedules, internal evaluation '
            'reports, the names of three programs that officially do not '
            'exist. That is the difference between suspicion and knowledge.',
      ),
      effect: Effect(
        deltas: {Metric.intel: 22, Metric.covertRisk: -10},
      ),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Anwerbung war eine Falle — die Gegenseite führte den Kontakt '
            'von Anfang an. Was jetzt an die Öffentlichkeit geht, bestimmen '
            'nicht wir.',
        'The recruitment was a trap — the other side ran the contact from '
            'day one. What goes public now is not our decision.',
      ),
      effect: Effect(
        deltas: {
          Metric.trust: -12,
          Metric.escalation: 10,
          Metric.publicPressure: 6,
        },
      ),
      exposed: true,
    ),
  ),

  // ── Cyber ──────────────────────────────────────────────────────────────
  Directive(
    id: 'cyber_cooling',
    domain: OpsDomain.cyber,
    name: const LText(
      'Sabotage: Kühlkreislauf eines Rechenzentrums',
      'Sabotage: data center cooling loop',
    ),
    description: const LText(
      'Zugriff auf die Gebäudeleittechnik einer Trainingsanlage. Kein '
          'Knall, kein Feuer — nur Temperaturen, die den Lauf abbrechen '
          'und Hardware altern lassen.',
      'Access to the building management system of a training facility. '
          'No bang, no fire — just temperatures that abort the run and age '
          'the hardware.',
    ),
    computeCost: 30,
    baseSuccess: 62,
    baseExposure: 42,
    success: const DirectiveOutcome(
      text: LText(
        'Der Trainingslauf bricht bei 71 Prozent ab, zwei Racks sind '
            'Totalverlust. Offizielle Ursache: Wartungsfehler. Wochen '
            'gewonnen, niemand weiß von wem.',
        'The training run aborts at 71 percent; two racks are a total '
            'loss. Official cause: maintenance error. Weeks bought, and '
            'nobody knows from whom.',
      ),
      effect: Effect(deltas: {Metric.cnCapability: -5, Metric.escalation: 6}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Das Implantat wird beim Routine-Audit gefunden, samt Artefakten '
            'aus dem eigenen Werkzeugkasten. Peking legt die Forensik auf '
            'den Tisch.',
        'The implant is found in a routine audit, complete with artifacts '
            'from our own toolkit. Beijing puts the forensics on the table.',
      ),
      effect: Effect(
        deltas: {
          Metric.trust: -15,
          Metric.escalation: 16,
          Metric.publicPressure: 8,
        },
      ),
      exposed: true,
    ),
  ),
  Directive(
    id: 'cyber_exfil',
    domain: OpsDomain.cyber,
    name: const LText(
      'Exfiltration von Trainings-Metadaten',
      'Exfiltrate training metadata',
    ),
    description: const LText(
      'Keine Gewichte — nur Logs, Konfigurationen, Rechenzeitbudgets. '
          'Weniger Ertrag, deutlich weniger Kriegsgrund.',
      'No weights — just logs, configurations, compute budgets. Less '
          'yield, considerably less casus belli.',
    ),
    computeCost: 22,
    baseSuccess: 66,
    baseExposure: 28,
    success: const DirectiveOutcome(
      text: LText(
        'Die Metadaten verraten mehr als erwartet: Laufzeiten, '
            'Clustergrößen, ein Sprung im Rechenbudget, der zu keinem '
            'gemeldeten Projekt passt.',
        'The metadata says more than expected: run times, cluster sizes, '
            'a jump in compute budget matching no declared project.',
      ),
      effect: Effect(deltas: {Metric.intel: 15, Metric.covertRisk: -6}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Verbindung wird mitten im Transfer gekappt. Was wir '
            'mitnehmen konnten, ist wertlos; was wir hinterlassen haben, '
            'ist es nicht.',
        'The connection is cut mid-transfer. What we took is worthless; '
            'what we left behind is not.',
      ),
      effect: Effect(deltas: {Metric.trust: -8, Metric.escalation: 8}),
      exposed: true,
    ),
  ),

  // ── Verdeckte Aktion ───────────────────────────────────────────────────
  Directive(
    id: 'covert_fab_equipment',
    domain: OpsDomain.kinetic,
    name: const LText(
      'Lieferkettensabotage: Fab-Ausrüstung',
      'Supply chain sabotage: fab equipment',
    ),
    description: const LText(
      'Eine Lithografie-Komponente auf dem Transportweg. Ein '
          'Kalibrierungsfehler, der erst nach Monaten Produktion auffällt '
          'und eine Fabrik zurückwirft.',
      'One lithography component in transit. A calibration error that '
          'only surfaces after months of production and sets a fab back.',
    ),
    computeCost: 45,
    baseSuccess: 52,
    baseExposure: 55,
    success: const DirectiveOutcome(
      text: LText(
        'Die Ausbeute der Ziel-Fab bricht ein, bevor jemand die Ursache '
            'findet. Ein halbes Jahr Produktionsvorsprung, erkauft mit '
            'einem Vorgang, der nie in einer Akte stehen darf.',
        'Yield at the target fab collapses before anyone finds the cause. '
            'Half a year of production lead, bought with an operation that '
            'must never appear in a file.',
      ),
      effect: Effect(
        deltas: {Metric.cnCapability: -7, Metric.escalation: 10},
      ),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Der Mittelsmann wird beim Zoll aufgegriffen und redet nach zwei '
            'Tagen. Was folgt, ist keine diplomatische Note, sondern eine '
            'Warnung.',
        'The cutout is picked up at customs and talks within two days. '
            'What follows is not a diplomatic note but a warning.',
      ),
      effect: Effect(
        deltas: {
          Metric.trust: -18,
          Metric.escalation: 22,
          Metric.publicPressure: 10,
        },
      ),
      exposed: true,
    ),
  ),

  // ── Täuschung ──────────────────────────────────────────────────────────
  Directive(
    id: 'false_flag',
    domain: OpsDomain.deception,
    name: const LText(
      'False-Flag-Operation',
      'False flag operation',
    ),
    description: const LText(
      'Ein Angriff auf ein chinesisches Rechenzentrum, ausgeführt mit den '
          'Werkzeugen und Signaturen eines Dritten. Wenn es aufgeht, '
          'streiten sich zwei andere. Wenn nicht, steht Amerika als das '
          'da, was seine Gegner behaupten.',
      'An attack on a Chinese data center, executed with a third party\'s '
          'tooling and signatures. If it works, two others fight. If not, '
          'America becomes exactly what its adversaries claim.',
    ),
    computeCost: 55,
    slots: 2,
    baseSuccess: 44,
    baseExposure: 62,
    success: const DirectiveOutcome(
      text: LText(
        'Die Attribution läuft ins Leere und dann in die falsche '
            'Richtung: Peking sucht den Schuldigen in einer dritten '
            'Hauptstadt. Der Trainingslauf ist tot, unsere Hände sind '
            'sauber — heute.',
        'Attribution goes nowhere, then the wrong way: Beijing looks for '
            'the culprit in a third capital. The training run is dead, our '
            'hands are clean — today.',
      ),
      effect: Effect(
        deltas: {
          Metric.cnCapability: -6,
          Metric.escalation: 12,
          Metric.covertRisk: 5,
        },
      ),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Ein Fehler in der untergeschobenen Signatur — ein Zeitstempel in '
            'der falschen Zeitzone. Peking weist die Fälschung nach und '
            'veröffentlicht alles. Es gibt keine Version dieser '
            'Geschichte, die gut für uns endet.',
        'One flaw in the planted signature — a timestamp in the wrong '
            'time zone. Beijing proves the forgery and publishes '
            'everything. There is no version of this story that ends well '
            'for us.',
      ),
      effect: Effect(
        deltas: {
          Metric.trust: -25,
          Metric.escalation: 25,
          Metric.publicPressure: 14,
          Metric.politicalCapital: -12,
        },
      ),
      exposed: true,
    ),
  ),
  Directive(
    id: 'deception_capability',
    domain: OpsDomain.deception,
    name: const LText(
      'Desinformation über eigene Fähigkeiten',
      'Disinformation about our own capabilities',
    ),
    description: const LText(
      'Gezielt gestreute Hinweise auf einen Durchbruch, den es nicht '
          'gibt. Abschreckung durch Bluff — solange niemand nachzählt.',
      'Deliberately seeded hints of a breakthrough that does not exist. '
          'Deterrence by bluff — as long as nobody counts.',
    ),
    computeCost: 15,
    baseSuccess: 60,
    baseExposure: 40,
    success: const DirectiveOutcome(
      text: LText(
        'Peking verschiebt Ressourcen in eine Sackgasse, um mit einem '
            'Programm gleichzuziehen, das nur in unseren Präsentationen '
            'existiert.',
        'Beijing shifts resources into a dead end to match a program that '
            'exists only in our slide decks.',
      ),
      effect: Effect(deltas: {Metric.cnCapability: -3, Metric.escalation: 5}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Legende bricht bei der ersten technischen Nachfrage. Ab '
            'jetzt gilt jede unserer Fähigkeitsangaben als Verhandlungs-'
            'taktik — auch die wahren.',
        'The legend collapses at the first technical question. From now '
            'on every capability statement we make counts as a bargaining '
            'tactic — including the true ones.',
      ),
      effect: Effect(deltas: {Metric.trust: -10, Metric.verification: -6}),
      exposed: true,
    ),
  ),

  // ── Beschaffung ────────────────────────────────────────────────────────
  Directive(
    id: 'data_purchase',
    domain: OpsDomain.procurement,
    name: const LText(
      'Datenkauf über Mittelsmänner',
      'Data purchase through cutouts',
    ),
    description: const LText(
      'Exklusive Korpora: Fachliteratur, Industrietelemetrie, '
          'Verhandlungsprotokolle. Legal grau, teuer, und der schnellste '
          'Weg zu besseren Modellen ohne neuen Compute.',
      'Exclusive corpora: technical literature, industrial telemetry, '
          'negotiation transcripts. Legally gray, expensive, and the '
          'fastest route to better models without new compute.',
    ),
    computeCost: 28,
    baseSuccess: 74,
    baseExposure: 24,
    success: const DirectiveOutcome(
      text: LText(
        'Die Korpora sind besser als erhofft — und sauber genug, dass die '
            'Herkunftsfrage in keiner Anhörung auftaucht. Die eigenen '
            'Modelle springen.',
        'The corpora are better than hoped — and clean enough that the '
            'provenance question never reaches a hearing. Our own models '
            'jump.',
      ),
      effect: Effect(deltas: {Metric.usCapability: 4, Metric.alignment: 2}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Ein Zwischenhändler verkauft dieselben Daten zweimal — die '
            'zweite Kopie liegt in Shenzhen. Bezahlt haben wir trotzdem.',
        'One broker sells the same data twice — the second copy sits in '
            'Shenzhen. We paid all the same.',
      ),
      effect: Effect(deltas: {Metric.cnCapability: 3, Metric.trust: -4}),
      exposed: true,
    ),
  ),
  Directive(
    id: 'gray_import',
    domain: OpsDomain.procurement,
    name: const LText(
      'Grauimport von Beschleunigern',
      'Gray-market accelerator import',
    ),
    description: const LText(
      'Beschlagnahmte Schmuggelware zurückkaufen, bevor sie ihren Weg '
          'nach Osten findet. Bringt Compute ins eigene Budget — und '
          'finanziert nebenbei genau die Netzwerke, die man bekämpft.',
      'Buy back seized smuggled hardware before it heads east. Adds '
          'compute to our own budget — and incidentally funds the very '
          'networks we are fighting.',
    ),
    computeCost: 10,
    baseSuccess: 68,
    baseExposure: 30,
    success: const DirectiveOutcome(
      text: LText(
        'Vierzigtausend Beschleuniger wechseln in einer Nacht den '
            'Besitzer. Auf dem Papier sind es Ersatzteile für '
            'Wetterrechner.',
        'Forty thousand accelerators change hands in a single night. On '
            'paper they are spare parts for weather computers.',
      ),
      computeDelta: 55,
      effect: Effect(deltas: {Metric.covertRisk: 4}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Lieferung ist zur Hälfte Attrappe, der Rest gebrandmarkt. '
            'Der Zoll stellt Fragen, auf die es keine gute Antwort gibt.',
        'Half the shipment is dummy hardware, the rest is flagged. '
            'Customs asks questions with no good answers.',
      ),
      computeDelta: -8,
      effect: Effect(deltas: {Metric.publicPressure: 6, Metric.trust: -4}),
      exposed: true,
    ),
  ),

  // ── Abwehr ─────────────────────────────────────────────────────────────
  Directive(
    id: 'counterintel_sweep',
    domain: OpsDomain.defensive,
    name: const LText(
      'Spionageabwehr-Sweep der eigenen Labs',
      'Counterintelligence sweep of our labs',
    ),
    description: const LText(
      'Hintergrundprüfungen, Netzwerkforensik, Zugriffsprotokolle der '
          'letzten zwei Jahre. Unbeliebt im Haus, unverzichtbar im Ernstfall.',
      'Background checks, network forensics, two years of access logs. '
          'Unpopular in-house, indispensable when it counts.',
    ),
    computeCost: 20,
    baseSuccess: 76,
    baseExposure: 4,
    success: const DirectiveOutcome(
      text: LText(
        'Zwei Zugänge werden geschlossen, ein Vertrag nicht verlängert. '
            'Die Gewichte der Spitzenmodelle sind heute sicherer als '
            'gestern.',
        'Two accesses are closed, one contract not renewed. The frontier '
            'weights are safer today than yesterday.',
      ),
      effect: Effect(deltas: {Metric.verification: 8, Metric.covertRisk: -7}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Der Sweep findet nichts außer schlechter Stimmung — und zwei '
            'Spitzenforscher kündigen wegen der Behandlung.',
        'The sweep finds nothing but bad blood — and two senior '
            'researchers resign over how they were treated.',
      ),
      effect: Effect(deltas: {Metric.usCapability: -2, Metric.verification: 2}),
    ),
  ),
  Directive(
    id: 'harden_clusters',
    domain: OpsDomain.defensive,
    name: const LText(
      'Härtung der eigenen Cluster',
      'Harden our own clusters',
    ),
    description: const LText(
      'Air-Gapping, Bandbreitendeckelung, Tamper-Sensorik, Faraday-'
          'Schirmung. Teuer in Compute und Zeit — die Grundlage jedes '
          'glaubwürdigen Verifikationsversprechens.',
      'Air gapping, bandwidth caps, tamper sensors, Faraday shielding. '
          'Expensive in compute and time — the basis of any credible '
          'verification promise.',
    ),
    computeCost: 35,
    baseSuccess: 82,
    baseExposure: 2,
    success: const DirectiveOutcome(
      text: LText(
        'Die Cluster erreichen das Sicherheitsniveau, das der Vertrag '
            'später verlangen wird. Wer jetzt vorbaut, verhandelt später '
            'aus Stärke.',
        'The clusters reach the security level the treaty will later '
            'demand. Building it now means negotiating from strength '
            'later.',
      ),
      effect: Effect(deltas: {Metric.verification: 11, Metric.covertRisk: -4}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Umrüstung legt zwei Cluster länger lahm als geplant. Das '
            'Sicherheitsniveau steigt, der Forschungsplan rutscht.',
        'The retrofit takes two clusters offline longer than planned. '
            'Security rises, the research schedule slips.',
      ),
      effect: Effect(deltas: {Metric.verification: 5, Metric.usCapability: -2}),
    ),
  ),

  // ── Diplomatie ─────────────────────────────────────────────────────────
  Directive(
    id: 'deconfliction_line',
    domain: OpsDomain.diplomatic,
    name: const LText(
      'Deeskalations-Draht nach Peking',
      'Deconfliction line to Beijing',
    ),
    description: const LText(
      'Ein ständiger militärischer Kanal für Zwischenfälle: verifizierte '
          'Identitäten, feste Ansprechpartner, keine Presse. Das '
          'unspektakulärste Instrument gegen den Krieg aus Versehen.',
      'A standing military channel for incidents: verified identities, '
          'fixed counterparts, no press. The least spectacular instrument '
          'against a war by accident.',
    ),
    computeCost: 12,
    baseSuccess: 80,
    baseExposure: 2,
    success: const DirectiveOutcome(
      text: LText(
        'Der Draht steht. Beim nächsten Zwischenfall vergehen zwischen '
            'Meldung und Klärung Minuten statt Tage — das kann der '
            'Unterschied sein.',
        'The line is up. At the next incident, minutes pass between '
            'report and clarification instead of days — that can be the '
            'difference.',
      ),
      effect: Effect(deltas: {Metric.escalation: -14, Metric.trust: 6}),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Peking lässt den Vorschlag unbeantwortet — man wolle keine '
            'Kanäle, die Vorfälle normalisieren. Der Draht bleibt tot.',
        'Beijing leaves the proposal unanswered — no interest in channels '
            'that normalize incidents. The line stays dead.',
      ),
      effect: Effect(deltas: {Metric.escalation: -3}),
    ),
  ),
  Directive(
    id: 'joint_incident_review',
    domain: OpsDomain.diplomatic,
    name: const LText(
      'Gemeinsame Vorfalluntersuchung anbieten',
      'Offer a joint incident review',
    ),
    description: const LText(
      'Beide Seiten legen ihre Forensik zu einem Zwischenfall offen. '
          'Riskant: Wer selbst operiert hat, riskiert die eigene Spur zu '
          'zeigen. Wirksam: nichts senkt die Eskalation schneller.',
      'Both sides open their forensics on an incident. Risky: if you ran '
          'the operation, you risk showing your own tracks. Effective: '
          'nothing lowers escalation faster.',
    ),
    computeCost: 16,
    baseSuccess: 64,
    baseExposure: 8,
    available: (s) => s.metric(Metric.escalation) >= 30,
    lockedHint: const LText(
      'Erst sinnvoll, wenn die Lage tatsächlich angespannt ist '
          '(Eskalation ab 30).',
      'Only meaningful once the situation is actually tense (escalation '
          '30 or above).',
    ),
    success: const DirectiveOutcome(
      text: LText(
        'Die gemeinsame Untersuchung entlastet beide Seiten teilweise und '
            'belastet einen Dritten. Wichtiger als das Ergebnis ist das '
            'Verfahren: Man redet wieder.',
        'The joint review partially clears both sides and implicates a '
            'third. More important than the result is the process: people '
            'are talking again.',
      ),
      effect: Effect(
        deltas: {
          Metric.escalation: -18,
          Metric.trust: 9,
          Metric.verification: 4,
        },
      ),
    ),
    failure: const DirectiveOutcome(
      text: LText(
        'Die Forensik der Gegenseite ist präziser als unsere Legende. Die '
            'Untersuchung endet im Streit, das Misstrauen sitzt tiefer als '
            'vorher.',
        'The other side\'s forensics are sharper than our legend. The '
            'review ends in argument, and the mistrust runs deeper than '
            'before.',
      ),
      effect: Effect(deltas: {Metric.trust: -8, Metric.escalation: 4}),
      exposed: true,
    ),
  ),
];
