// lib/main.dart
// Entry point de Fénix Pocket OS V5.
// Inicializa el SplashCheck que verifica UUID en SecureStorage.
// Si existe → MainMenuScreen. Si no → WelcomeScreen (3 campos onboarding).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/app_config.dart';
import 'views/auth/welcome_screen.dart';
import 'views/main/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forzar orientación vertical (UX de Fénix: lista de chat vertical)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FenixApp());
}

class FenixApp extends StatelessWidget {
  const FenixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fénix Pocket OS V5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF13131A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D12),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4C8CFA),
          secondary: Color(0xFFD4AF37), // Oro para acentos (del README V2)
          surface: Color(0xFF1A1A24),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white54),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4C8CFA))),
        ),
      ),
      home: const SplashCheck(),
    );
  }
}

/// SplashScreen implícito: verifica si hay UUID v4 en Keychain.
/// Si existe → navega al MainMenu (con Drawer lateral).
/// Si no → navega al WelcomeScreen (3 campos onboarding).
class SplashCheck extends StatefulWidget {
  const SplashCheck({Key? key}) : super(key: key);

  @override
  State<SplashCheck> createState() => _SplashCheckState();
}

class _SplashCheckState extends State<SplashCheck> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _verificarUuid();
  }

  Future<void> _verificarUuid() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Splash mínimo
    final userId = await _storage.read(key: 'user_id');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => userId != null && userId.isNotEmpty
            ? const MainMenuScreen()
            : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_moon_outlined, size: 80, color: Color(0xFF4C8CFA)),
            const SizedBox(height: 24),
            Text('Fénix Pocket OS',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('v${AppConfig.appVersion} • A.G.O.S. Stateless Subconscious',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF4C8CFA)),
          ],
        ),
      ),
    );
  }
}
