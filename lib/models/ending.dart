import 'lang.dart';

/// Ausgang einer Partie.
enum EndingTone { triumph, mixed, defeat }

class Ending {
  final String id;
  final LText title;
  final LText description;
  final EndingTone tone;

  /// Quelle im Regelwerk (z. B. 'AI 2040: Plan A — Lightcone-Ende').
  final LText? source;

  const Ending({
    required this.id,
    required this.title,
    required this.description,
    required this.tone,
    this.source,
  });
}
