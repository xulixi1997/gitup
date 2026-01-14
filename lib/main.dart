import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/game_engine.dart';
import 'screens/boot_screen.dart';

import 'core/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Hide system UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, GameEngine>(
          create: (_) => GameEngine(),
          update: (context, settings, engine) {
            final e = engine ?? GameEngine();
            e.updateSettings(settings);
            return e;
          },
        ),
      ],
      child: const GlitchApp(),
    ),
  );
}

class GlitchApp extends StatelessWidget {
  const GlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLITCH_KATANA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'monospace',
      ),
      home: const BootScreen(),
    );
  }
}
