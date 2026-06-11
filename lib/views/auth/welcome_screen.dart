// lib/views/auth/welcome_screen.dart
// Onboarding ceremonial V5: 3 campos (ID, Rol, Metavariable) + ENGRAVE SYSTEM.IO.
// Genera UUID v4 + master_key AES-256 + EAV en SQLite local.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../services/perfil_db_service.dart';
import '../main/main_menu_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _profesionController = TextEditingController();
  final _metaController = TextEditingController();

  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();
  bool _isLoading = false;

  Future<void> _iniciarEcosistema() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. UUID v4 anónimo (multi-tenant)
      final userId = _uuid.v4();
      await _storage.write(key: 'user_id', value: userId);

      // 2. Master key AES-256 simétrica (bóveda cifrada)
      final rand = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => rand.nextInt(256));
      final masterKey = base64UrlEncode(keyBytes);
      await _storage.write(key: 'master_key_aes256', value: masterKey);

      // 3. EAV en SQLite (PerfilDbService)
      final db = PerfilDbService();
      await db.initDb();
      await db.upsertEav('identidad', 'nombre_usuario', _nombreController.text.trim());
      await db.upsertEav('identidad', 'profesion_activa', _profesionController.text.trim());
      await db.upsertEav('identidad', 'meta_dominante', _metaController.text.trim());
      await db.upsertEav('sistema', 'config_inicial', 'Activa');
      await db.upsertEav('sistema', 'fecha_onboarding', DateTime.now().toIso8601String());

      // 4. Navega al MainMenu (hub con 6 secciones)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Colapso criptográfico o SQLite err: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_moon_outlined, size: 72, color: Color(0xFF4C8CFA)),
                const SizedBox(height: 24),
                const Text(
                  'Fénix Pocket OS',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arranque en Bóveda Cero-Conocimiento',
                  style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 48),
                _campoTexto(_nombreController, 'ID / Denominación'),
                const SizedBox(height: 16),
                _campoTexto(_profesionController, 'Rol Funcional o Profesión'),
                const SizedBox(height: 16),
                _campoTexto(_metaController, 'Metavariable (Objetivo Maestro)'),
                const SizedBox(height: 56),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4C8CFA))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _iniciarEcosistema,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C8CFA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'ENGRAVE SYSTEM.IO',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (val) => val != null && val.isNotEmpty ? null : 'Requisito bloqueante.',
    );
  }
}
