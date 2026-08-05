import 'lang.dart';

/// Kennzahlen der Weltlage. Alle Werte 0–100, sofern nicht anders angegeben.
enum Metric {
  /// KI-Fähigkeitsniveau der führenden US-Labs (Meilenstein-Skala).
  usCapability,

  /// KI-Fähigkeitsniveau der führenden chinesischen Labs.
  cnCapability,

  /// Fortschritt der Alignment-/Kontrollforschung.
  alignment,

  /// Gegenseitiges Vertrauen zwischen USA und China.
  trust,

  /// Güte des Verifikationsregimes (Inspektionen, Chip-Tracking, HEMs).
  verification,

  /// Öffentlicher Druck / Awareness für KI-Risiken.
  publicPressure,

  /// Ökonomischer und politischer Spielraum der eigenen Regierung.
  politicalCapital,

  /// Risiko, dass irgendwo ein verdecktes Frontier-Projekt läuft.
  covertRisk,

  /// Eskalationsstufe zwischen den Blöcken. 100 = offener Krieg.
  escalation,

  /// Güte der eigenen Aufklärungslage (SIGINT/HUMINT/IMINT).
  intel,
}

extension MetricInfo on Metric {
  LText get labelText => switch (this) {
    Metric.usCapability => const LText('KI-Niveau USA', 'US AI level'),
    Metric.cnCapability => const LText('KI-Niveau China', 'China AI level'),
    Metric.alignment => const LText(
      'Alignment-Forschung',
      'Alignment research',
    ),
    Metric.trust => const LText('Vertrauen USA–China', 'US–China trust'),
    Metric.verification => const LText(
      'Verifikationsregime',
      'Verification regime',
    ),
    Metric.publicPressure => const LText(
      'Öffentlicher Druck',
      'Public pressure',
    ),
    Metric.politicalCapital => const LText(
      'Politisches Kapital',
      'Political capital',
    ),
    Metric.covertRisk => const LText(
      'Risiko verdeckter Projekte',
      'Covert project risk',
    ),
    Metric.escalation => const LText('Eskalationsstufe', 'Escalation level'),
    Metric.intel => const LText('Aufklärungslage', 'Intelligence picture'),
  };

  String label(AppLang lang) => labelText.t(lang);

  String get id => name;
}

/// Meilensteine der Fähigkeits-Skala, angelehnt an AI 2027 / AI 2040.
class CapabilityMilestones {
  static const double superhumanCoder = 30;
  static const double superhumanResearcher = 55;
  static const double expertLevel = 75; // Pausenlinie von Plan A
  static const double superintelligence = 100;

  static String labelFor(double value, AppLang lang) {
    final l = switch (value) {
      >= superintelligence => const LText(
        'Superintelligenz',
        'Superintelligence',
      ),
      >= expertLevel => const LText(
        'Expertenniveau (Pausenlinie)',
        'Expert level (pause line)',
      ),
      >= superhumanResearcher => const LText(
        'Übermenschlicher KI-Forscher',
        'Superhuman AI researcher',
      ),
      >= superhumanCoder => const LText(
        'Übermenschlicher Programmierer',
        'Superhuman coder',
      ),
      _ => const LText('Agentische Assistenten', 'Agentic assistants'),
    };
    return l.t(lang);
  }
}
