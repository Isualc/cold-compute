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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'Cold Compute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const StartScreen(),
      ),
    );
  }
}
