import '../models/lang.dart';

/// UI-Texte außerhalb der Szenario-Daten.
class Strings {
  final AppLang lang;
  const Strings(this.lang);

  bool get _de => lang == AppLang.de;

  // Startscreen
  String get appName => 'COLD COMPUTE';
  String get subtitle => _de
      ? 'DAS RENNEN UM DIE SUPERINTELLIGENZ'
      : 'THE RACE FOR SUPERINTELLIGENCE';
  String get intro => _de
      ? 'Pen-and-Paper-Simulation des kalten Krieges um Rechenleistung, von '
            '2026 bis 2040. Du berätst das Weiße Haus im Ringen um eine '
            'kontrollierte Superintelligenz, der Spielleiter würfelt, die '
            'Welt reagiert.'
      : 'A pen-and-paper simulation of the cold war over compute, from 2026 '
            'to 2040. You advise the White House in the struggle for a '
            'controlled superintelligence, the game master rolls the dice, '
            'and the world reacts.';

  /// Quellenzeile: erlaubte Nennung, klare Abgrenzung.
  String get attribution => _de
      ? 'Szenariospiel nach „AI 2040: Plan A" des AI Futures Project. '
            'Unabhängiges Fan-Projekt, nicht mit dem AI Futures Project '
            'verbunden und von diesem weder geprüft noch unterstützt.'
      : 'A scenario game based on "AI 2040: Plan A" by the AI Futures '
            'Project. Independent fan project, not affiliated with, '
            'reviewed or endorsed by the AI Futures Project.';

  /// Kurzform für Fußzeilen.
  String get attributionShort => _de
      ? 'NACH „AI 2040: PLAN A" DES AI FUTURES PROJECT · NICHT VERBUNDEN'
      : 'BASED ON "AI 2040: PLAN A" BY THE AI FUTURES PROJECT · UNAFFILIATED';
  String get chooseRole => _de ? 'ROLLE WÄHLEN' : 'CHOOSE YOUR ROLE';
  String get newGame => _de ? 'Neue Partie beginnen' : 'Start a new game';
  String get continueGame => _de ? 'Partie fortsetzen' : 'Continue game';
  String get codexButton =>
      _de ? 'Codex — Regelwerk & Hintergrund' : 'Codex — rules & background';
  String get statsButton =>
      _de ? 'Statistik & Historie' : 'Statistics & history';
  String get statsTitle => _de ? 'Statistik' : 'Statistics';

  // GameScreen
  String get worldState => _de ? 'WELTLAGE' : 'WORLD STATE';
  String get usFrontier => _de ? 'US-Frontier' : 'US frontier';
  String get china => 'China';
  String get protocol => _de ? 'PROTOKOLL' : 'SESSION LOG';
  String get nextHalfYear => _de ? 'Nächstes Halbjahr' : 'Next half-year';
  String get decision => _de ? 'ENTSCHEIDUNG' : 'DECISION';
  String get next => _de ? 'Weiter' : 'Continue';
  String get die => _de ? 'W20' : 'D20';
  String get situation => _de ? 'Lage' : 'Situation';
  String get briefing => _de ? 'Briefing' : 'Briefing';
  String get chronicle => _de ? 'Chronik' : 'Chronicle';

  // Operationen
  String get operations => _de ? 'Ops' : 'Ops';
  String get opsTitle => _de ? 'VERDECKTE OPERATIONEN' : 'COVERT OPERATIONS';
  String get opsBudget => _de ? 'Compute-Budget' : 'Compute budget';
  String get opsSlots => _de ? 'Stabskapazität' : 'Staff capacity';
  String get opsChance => _de ? 'Erfolg' : 'Success';
  String get opsExposure => _de ? 'Attribution' : 'Attribution';
  String get opsCost => _de ? 'Kosten' : 'Cost';
  String get opsExecute => _de ? 'Anordnen' : 'Execute';
  String get opsNoBudget =>
      _de ? 'Budget oder Kapazität erschöpft' : 'Budget or capacity exhausted';
  String get opsSpent => _de
      ? 'Alle Operationsslots dieses Halbjahres sind verbraucht.'
      : 'All operation slots for this half-year are used up.';

  // Ending
  String get gameOver => _de ? 'PARTIE BEENDET' : 'GAME OVER';
  String get backToStart => _de ? 'Zurück zum Start' : 'Back to start';
  String get statAlignment => 'Alignment';
  String get statTrust => _de ? 'Vertrauen' : 'Trust';
  String get statVerification => _de ? 'Verifikation' : 'Verification';

  // Codex
  String get codexTitle => 'Codex';
}
