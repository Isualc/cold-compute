/// Unterstützte Sprachen der Simulation.
enum AppLang { de, en }

extension AppLangInfo on AppLang {
  String get label => switch (this) {
    AppLang.de => 'Deutsch',
    AppLang.en => 'English',
  };
}

/// Zweisprachiger Text: Deutsch zuerst, Englisch als zweites Argument.
class LText {
  final String de;
  final String en;

  const LText(this.de, this.en);

  String t(AppLang lang) => lang == AppLang.en ? en : de;
}
