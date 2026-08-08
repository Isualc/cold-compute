import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/start_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ColdComputeApp());
}

class ColdComputeApp extends StatelessWidget {
  const ColdComputeApp({super.key});

  /// Ab ~1440 px logischer Breite wächst die gesamte Oberfläche mit,
  /// gedeckelt bei 160 %: Große Monitore bekommen größere Schrift und
  /// Bedienelemente statt mehr leerer Fläche.
  static double uiScaleFor(Size size) => (size.width / 1440).clamp(1.0, 1.6);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'Cold Compute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          final media = MediaQuery.of(context);
          final scale = uiScaleFor(media.size);
          if (scale <= 1.001) return child;
          // Die App layoutet auf einer verkleinerten logischen Fläche und
          // wird als Ganzes hochskaliert — so bleiben alle Layout-Brüche
          // (Breakpoints, Spaltenbreiten) konsistent zum Zoomfaktor.
          final logical = Size(
            media.size.width / scale,
            media.size.height / scale,
          );
          return FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: logical.width,
              height: logical.height,
              child: MediaQuery(
                data: media.copyWith(size: logical),
                child: child,
              ),
            ),
          );
        },
        home: const StartScreen(),
      ),
    );
  }
}
