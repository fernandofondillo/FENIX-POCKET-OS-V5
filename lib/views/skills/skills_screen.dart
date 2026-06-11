// lib/views/skills/skills_screen.dart
// Catálogo de 5 skills built-in de V5 (leídas desde SkillsService).
// Integra SkillsService.listar_habilidades_permitidas() y leer_historial_skills().

import 'package:flutter/material.dart';
import '../../services/skills_service.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({Key? key}) : super(key: key);

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _skills = SkillsService();
  List<Map<String, dynamic>> _historial = [];

  final Map<String, String> _descripciones = {
    'agenda_crear': 'Programa eventos en tu calendario local con recordatorios.',
    'notificacion_enviar': 'Manda notificaciones push desde el VPS Soberano.',
    'web_search': 'Búsqueda web en tiempo real (Whisper pipeline).',
    'memoria_recordar': 'Almacena un dato en Nano-Obsidian Vault cifrado.',
    'memoria_olvidar': 'Borra un dato específico del vault (GDPR).',
  };

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    await _skills.init();
    final h = await _skills.leer_historial_skills();
    if (mounted) setState(() => _historial = h);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('SKILLS NATIVAS',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.layers_outlined, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '5 skills built-in. Fénix las invoca automáticamente si detecta triggers <skill> en su respuesta.',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...SkillsService.built_in.map((id) => _buildSkillCard(id)),
          const SizedBox(height: 24),
          if (_historial.isNotEmpty) ...[
            const Text('HISTORIAL DE INVOCACIONES',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            ..._historial.take(10).map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '[${h['timestamp']}] ${h['skill_name']}',
                    style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillCard(String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4C8CFA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF4C8CFA), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                Text(_descripciones[id] ?? '', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
