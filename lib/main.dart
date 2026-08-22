import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/multiplayer/presentation/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DerinKaziApp(),
    ),
  );
}

class DerinKaziApp extends StatelessWidget {
  const DerinKaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derin Kazı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainMenuScreen(),
    );
  }
}

