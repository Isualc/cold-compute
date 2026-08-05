import 'lang.dart';
import 'metrics.dart';

/// Spielbare Rolle im Pen-and-Paper, nach dem Rollen-Vorbild der
/// Tabletop Exercise des AI Futures Project.
class Role {
  final String id;
  final LText name;
  final LText description;

  /// Perspektive, aus der Ereignistexte formuliert werden.
  final String perspective;

  /// Start-Modifikatoren auf die Weltlage — das mechanische Profil der
  /// Rolle (z. B. bringt der Lab-CEO Fähigkeit mit, aber wenig Rückhalt
  /// in Washington).
  final Map<Metric, double> startModifiers;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.perspective,
    this.startModifiers = const {},
  });
}
